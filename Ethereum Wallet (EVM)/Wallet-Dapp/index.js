var express = require("express");
var app = express();
app.use(express.static("src"));

app.get("/", (req, res) => {
    res.render("index.html");
});

app.listen(3000, () => {
    console.log("DApp is listening on port 3000");
});
