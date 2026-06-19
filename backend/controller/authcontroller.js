const pool = require("../db");
const jwt = require("jsonwebtoken");
const registerUser = async (req, res) => {
  try {
    const { name, gmail, password, mobile_no, Address } = req.body;

    if (!name || !gmail || !password || !mobile_no || !Address) {
      return res.status(400).json({ error: "All fields are required" });
    }

    const checkUser = await pool.query(
      "SELECT * FROM public.login WHERE gmail = $1 OR mobile_no = $2",
      [gmail, mobile_no]
    );

    if (checkUser.rows.length > 0) {
      return res.status(409).json({
        error: "User already exists with this gmail or mobile number",
      });
    }

    const result = await pool.query(
      `INSERT INTO public.login(name, gmail, password, mobile_no, "Address")
       VALUES($1, $2, $3, $4, $5)
       RETURNING *`,
      [name, gmail, password, mobile_no, Address]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: "Server Error" });
  }
};



const loginUser = async (req, res) => {
  try {
    const { gmail, password } = req.body;

    if (!gmail || !password) {
      return res.status(400).json({ error: "Gmail and password are required" });
    }
    const result = await pool.query(
      "SELECT id, name, gmail, mobile_no FROM login WHERE gmail=$1 AND password=$2",
      [gmail, password]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Invalid gmail or password",
      });
    }

    const token = jwt.sign(
      { id: result.rows[0].id, gmail: result.rows[0].gmail },
      pool.query("SELECT jwtSecret FROM login WHERE id = $1", [result.rows[0].id]).then(res => res.rows[0].jwtSecret)
    );

    res.json({
      success: true,
      token: token,
      user: result.rows[0],
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  registerUser,
  loginUser,
};