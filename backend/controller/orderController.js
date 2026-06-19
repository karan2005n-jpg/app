const pool = require("../db");

const createOrder = async (req, res) => {

  try {

    const {
      dealer_id,
      estimated_total,
      created_by,
      updated_by,
      cart
    } = req.body;

    
    const orderNo = "ORD-" + Date.now();

    
    const orderResult = await pool.query(
      `
      INSERT INTO public.orders(
        order_no,
        dealer_id,
        estimated_total,
        created_at,
        updated_at,
        created_by,
        updated_by
      )
      VALUES($1,$2,$3,NOW(),NOW(),$4,$5)
      RETURNING order_id
      `,
      [
        orderNo,
        dealer_id,
        estimated_total,
        created_by,
        updated_by
      ]
    );

    const orderId = orderResult.rows[0].order_id;

    
    for (const item of cart) {

      await pool.query(
        `
        INSERT INTO public.order_items(
          order_id,
          product_id,
          product_name,
          length_ft,
          qty,
          weight_ton,
          unit_price_per_ton,
          created_at,
          updated_at,
          created_by,
          updated_by
        )
        VALUES(
          $1,$2,$3,$4,$5,$6,$7,NOW(),NOW(),$8,$9
        )
        `,
        [
          orderId,
          item.product_id,
          item.product_name,
          item.length_ft,
          item.qty,
          item.weight_ton,
          item.unit_price_per_ton,
          created_by,
          updated_by
        ]
      );

    }

    res.status(201).json({
      success: true,
      message: "Order Created Successfully",
      order_id: orderId,
      order_no: orderNo
    });

  } catch (error) {

    console.log(error.message);

    res.status(500).json({
      success: false,
      error: error.message
    });

  }

};




const getOrders = async (req, res) => {

  try {

    const result = await pool.query(
      `
      SELECT

        o.order_id,
        o.order_no,
        o.dealer_id,
        o.estimated_total,
        o.created_at,

        oi.order_item_id,
        oi.product_id,
        oi.product_name,
        oi.length_ft,
        oi.qty,
        oi.weight_ton,
        oi.unit_price_per_ton

      FROM public.orders o

      INNER JOIN public.order_items oi
      ON o.order_id = oi.order_id

      ORDER BY o.order_id DESC
      `
    );

    res.status(200).json(result.rows);

  } catch (error) {

    console.log(error.message);

    res.status(500).json({
      success: false,
      error: error.message
    });

  }

};

module.exports = {
  createOrder,
  getOrders
};