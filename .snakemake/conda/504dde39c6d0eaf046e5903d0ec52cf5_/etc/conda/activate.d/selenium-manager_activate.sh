if [ "${SE_MANAGER_PATH+x}" ] ; then
  export SE_MANAGER_PATH_CONDA_BACKUP="${SE_MANAGER_PATH}"
fi
export SE_MANAGER_PATH="${CONDA_PREFIX}/bin/selenium-manager"
