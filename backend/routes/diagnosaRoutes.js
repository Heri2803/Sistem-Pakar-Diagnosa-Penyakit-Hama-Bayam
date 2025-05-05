const express = require('express');
const router = express.Router();
const diagnosaController = require('../controller/diagnosaController');

/**
 * @swagger
 * /api/diagnosa/bayes:
 *   post:
 *     summary: Melakukan diagnosa penyakit dan hama menggunakan Teorema Bayes
 *     tags: [Diagnosa]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               gejala:
 *                 type: array
 *                 items:
 *                   type: integer
 *                 example: [1, 2, 3]
 *     responses:
 *       200:
 *         description: Hasil diagnosa berhasil dikembalikan
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 penyakit:
 *                   type: object
 *                 hama:
 *                   type: object
 *       400:
 *         description: Permintaan tidak valid
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.post('/bayes', diagnosaController.diagnosaBayes);

module.exports = router;
