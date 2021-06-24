module.exports = {
  apps : [{
    name: "Socket",
    script: "./Socket/index.js",
    exp_backoff_restart_delay: 500,
    restart_delay: 2000,
    watch: true,
    watch_delay: 1000,
    error_file: "err.log",
    out_file: "out.log",
    env: {
      NODE_ENV: "development",
      TZ: "Asia/Kolkata"
    },
    env_production: {
      NODE_ENV: "production",
      TZ: "Asia/Kolkata"
    }
  },{
    name: "Tournament",
    script: "./Tournament/index.js",
    exp_backoff_restart_delay: 500,
    restart_delay: 2000,
    watch: true,
    watch_delay: 1000,
    error_file: "err.log",
    out_file: "out.log",
    env: {
      NODE_ENV: "development",
      TZ: "Asia/Kolkata"
    },
    env_production: {
      NODE_ENV: "production",
      TZ: "Asia/Kolkata"
    }
  },{
    name: "nodeApi",
    script: "./nodeApi/index.js",
    exp_backoff_restart_delay: 500,
    restart_delay: 2000,
    watch: true,
    watch_delay: 1000,
    error_file: "err.log",
    out_file: "out.log",
    env: {
      NODE_ENV: "development",
      TZ: "Asia/Kolkata"
    },
    env_production: {
      NODE_ENV: "production",
      TZ: "Asia/Kolkata"
    }
  }]
};
