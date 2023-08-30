[Unit]
Description=My Script Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User={{{station_config.easycast_user}}}
WorkingDirectory={{{station_config.easycast_user_home}}}/easycast
ExecStart={{{station_config.easycast_user_home}}}/easycast/bin/start

[Install]
WantedBy=multi-user.target
