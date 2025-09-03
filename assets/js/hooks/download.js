const Download = {
  mounted() {
    this.handleEvent("download-csv", ({ data, filename }) => {
      const blob = new Blob([data], { type: "text/csv;charset=utf-8;" });

      const url = URL.createObjectURL(blob);

      const link = document.createElement("a");
      link.href = url;
      link.download = filename;
      link.style.display = "none";

      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      URL.revokeObjectURL(url);
    });
  },
};

export default Download;
