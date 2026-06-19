const pool = require("../db");

const getAllProducts = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        pc.category_id,
        pc.category_name,
        pc.category_code,

        p.product_id,
        p.product_name,
        p.description,
        p.unit_price_per_ton,
        p.stock_tons,

        pv.variant_id,
        pv.size_label,
        pv.length_ft,
        pv.weight_ton,
        pv.unit_price_per_ton AS variant_price

      FROM public.product_categories pc
      INNER JOIN public.products p
        ON pc.category_id = p.category_id
      INNER JOIN public.product_variants pv
        ON p.product_id = pv.product_id
      WHERE pc.is_active = 1
        AND p.is_active = 1
        AND pv.is_active = 1
      ORDER BY p.product_id;
    `);

    res.status(200).json(result.rows);
    
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ error: error.message });
  }
};

const addProduct = async (req, res) => {
  try {
    const {
      category_id,
      product_name,
      description,
      unit_price_per_ton,
      stock_tons,
      default_length_ft,
      min_custom_length_ft,
      max_custom_length_ft,
      created_by,
      updated_by,
    } = req.body;

    const result = await pool.query(
      `
      INSERT INTO public.products(
        category_id,
        product_name,
        description,
        unit_price_per_ton,
        stock_tons,
        default_length_ft,
        min_custom_length_ft,
        max_custom_length_ft,
        is_active,
        created_at,
        updated_at,
        created_by,
        updated_by
      )
      VALUES($1,$2,$3,$4,$5,$6,$7,$8,1,NOW(),NOW(),$9,$10)
      RETURNING *;
      `,
      [
        category_id,
        product_name,
        description,
        unit_price_per_ton,
        stock_tons,
        default_length_ft,
        min_custom_length_ft,
        max_custom_length_ft,
        created_by,
        updated_by,
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.log(error.message);
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getAllProducts,
  addProduct,
};