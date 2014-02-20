# audit_cron_allow
#
# The cron.allow and at.allow files are a list of users who are allowed to run
# the crontab and at commands to submit jobs to be run at scheduled intervals.
# On many systems, only the system administrator needs the ability to schedule
# jobs.
# Note that even though a given user is not listed in cron.allow, cron jobs can
# still be run as that user. The cron.allow file only controls administrative
# access to the crontab command for scheduling and modifying cron jobs.
# Much more effective access controls for the cron system can be obtained by
# using Role-Based Access Controls (RBAC).
# Note that if System Accounting is enabled, add the user sys to the cron.allow
# file in addition to the root account.
#.

audit_cron_allow () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    funct_verbose_message "At/Cron Authorized Users"
    check_file="/etc/cron.deny"
    funct_file_exists $check_file no
    check_file="/etc/at.deny"
    funct_file_exists $check_file no
    check_file="/etc/cron.allow"
    funct_file_exists $check_file yes
    if [ "$audit_mode" = 0 ]; then
      if [ "$os_name" = "SunOS" ]; then
        if [ "`cat $check_file |wc -l`" = "0" ]; then
          dir_name="/var/spool/cron/crontabs"
          if [ -d "$dir_name" ]; then
            for user_name in `ls $dir_name`; do
              check_id=`cat /etc/passwd |grep '^$user_name' |cut -f 1 -d:`
              if [ "$check_id" = "$user_name" ]; then
                echo "$user_name" >> $check_file
              fi
            done
          fi
        fi
      fi
      if [ "$os_name" = "Linux" ]; then
        if [ "`cat $check_file |wc -l`" = "0" ]; then
          dir_name="/var/spool/cron"
          if [ -d "$dir_name" ]; then
            for user_name in `ls $dir_name`; do
              check_id=`cat /etc/passwd |grep '^$user_name' |cut -f 1 -d:`
              if [ "$check_id" = "$user_name" ]; then
                echo "$user_name" >> $check_file
              fi
            done
          fi
        fi
      fi
      if [ "$os_name" = "Linux" ]; then
        for dir_name in /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.yearly; do
          if [ -d "$dir_name" ]; then
            for user_name in `ls -l $dir_name grep '-' |awk '{print $4}' |uniq`; do
              user_check=`cat $check_file |grep ''$user_name''`
              if [ "$user_check" != "$user_name" ]; then
                echo "$user_name" >> $check_file
              fi
            done
          fi
        done
      fi
    fi
    funct_check_perms $check_file 0640 root root
    check_file="/etc/at.allow"
    funct_file_exists $check_file yes
    if [ "$audit_mode" = 0 ]; then
      if [ "$os_name" = "SunOS" ]; then
        if [ "`cat $check_file |wc -l`" = "0" ]; then
          dir_name="/var/spool/cron/atjobs"
          if [ -d "$dir_name" ]; then
            for user_name in `ls $dir_name`; do
              user_check=`cat $check_file |grep ''$user_name''`
              if [ "$user_check" != "$user_name" ]; then
                echo "$user_name" >> $check_file
              fi
            done
          fi
        fi
      fi
      if [ "$os_name" = "Linux" ]; then
        if [ "`cat $check_file |wc -l`" = "0" ]; then
          dir_name="/var/spool/at/spool"
          if [ -d "$dir_name" ]; then
            for user_name in `ls /var/spool/at/spool`; do
              user_check=`cat $check_file |grep ''$user_name''`
              if [ "$user_check" != "$user_name" ]; then
                echo "$user_name" >> $check_file
              fi
            done
          fi
        fi
      fi
    fi
    funct_check_perms $check_file 0640 root root
    if [ "$os_name" = "Linux" ]; then
      for dir_name in /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.yearly; do
        funct_check_perms $dir_name 0640 root root
      done
      check_file="/etc/crontab"
      funct_check_perms $check_file 0640 root root
      check_file="/etc/anacrontab"
      funct_check_perms $check_file 0640 root root
    fi
  fi
}