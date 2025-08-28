export default {
  mounted() {
    const ua = navigator.userAgent || "";
    let os = "unknown";
    if (/Macintosh|Mac OS X/i.test(ua)) os = "mac";
    else if (/Windows NT/i.test(ua)) os = "windows";
    else if (/Linux/i.test(ua)) os = "linux";
    this.pushEvent("platform_info", { os, ua });
  },
};
