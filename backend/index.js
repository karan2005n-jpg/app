require("dotenv").config();

const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

const productsroutes = require("./routes/productsroutes");
const authroutes = require("./routes/authroutes");
const orderRoutes = require("./routes/orderRoutes");


app.use("/products", productsroutes);
app.use("/auth", authroutes);
app.use("/orders", orderRoutes);
const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`postgreSQL connected successfully`);
});

