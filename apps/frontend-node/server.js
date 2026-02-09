const express = require("express");
const axios = require("axios");

const app = express();
const BACKEND = process.env.BACKEND_URL || "http://backend:8080";

app.get("/", async (req, res) => {
  const r = await axios.get(BACKEND);
  res.send("Frontend → " + r.data);
});

app.listen(3000, () => console.log("Frontend on 3000"));

