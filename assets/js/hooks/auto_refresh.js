export default {
  mounted() {
    this.intervalId = null;
    this.startTimer();
  },

  updated() {
    this.startTimer();
  },

  startTimer() {
    this.stopTimer();
    const seconds = parseInt(this.el.dataset.seconds, 10);
    if (seconds && seconds > 0) {
      this.intervalId = setInterval(() => {
        this.pushEvent("auto_refresh_tick", {});
      }, seconds * 1000);
    }
  },

  stopTimer() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  },

  destroyed() {
    this.stopTimer();
  }
};
