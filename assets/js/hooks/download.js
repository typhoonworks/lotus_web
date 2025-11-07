const UrlOpener = {
  mounted() {
    this.handleEvent("open-url", ({ url }) => {
      window.open(url, '_blank');
    });
  },
};

export default UrlOpener;
