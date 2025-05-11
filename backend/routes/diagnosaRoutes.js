const express = require('express');
const router = express.Router();
const { diagnosa } = require('../controller/diagnosaController');
const roleMiddleware = require('../middleware/roleMiddleware');
console.log('Diagnosa function:', diagnosa); 

/**
 * @swagger
 * /api/diagnosa:
 *   post:
 *     summary: Melakukan diagnosa penyakit dan hama menggunakan Teorema Bayes
 *     tags: [Diagnosa]
 *     security:
 *       - BearerAuth: []
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
 *                 input_gejala:
 *                   type: array
 *                   description: Daftar gejala yang diinputkan user
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       kode:
 *                         type: string
 *                       nama:
 *                         type: string
 *                 hasil_gabungan:
 *                   type: array
 *                   description: Hasil gabungan hama dan penyakit berdasarkan probabilitas tertinggi
 *                   items:
 *                     type: object
 *                     properties:
 *                       type:
 *                         type: string
 *                         enum: [penyakit, hama]
 *                       nama:
 *                         type: string
 *                       probabilitas:
 *                         type: number
 *                       P_H:
 *                         type: number
 *                         description: Prior probability
 *                       P_E:
 *                         type: number
 *                         description: Evidence probability
 *                 penyakit:
 *                   type: array
 *                   description: Hasil diagnosa penyakit dengan perhitungan Bayes
 *                   items:
 *                     type: object
 *                     properties:
 *                       id_penyakit:
 *                         type: integer
 *                       nama:
 *                         type: string
 *                       P_H:
 *                         type: number
 *                         description: Prior probability penyakit
 *                       P_E:
 *                         type: number
 *                         description: Evidence probability
 *                       evidences:
 *                         type: array
 *                         items:
 *                           type: object
 *                           properties:
 *                             id_gejala:
 *                               type: integer
 *                             P_E_given_H:
 *                               type: number
 *                               description: Likelihood (nilai pakar gejala)
 *                       posterior_numerator:
 *                         type: number
 *                         description: Hasil perkalian P(E|H) * P(H)
 *                       posterior_probability:
 *                         type: number
 *                         description: P(H|E) - Hasil akhir teorema Bayes
 *                       probabilitas:
 *                         type: number
 *                         description: Nilai probabilitas untuk kompatibilitas
 *                 hama:
 *                   type: array
 *                   description: Hasil diagnosa hama dengan perhitungan Bayes
 *                   items:
 *                     type: object
 *                     properties:
 *                       id_hama:
 *                         type: integer
 *                       nama:
 *                         type: string
 *                       P_H:
 *                         type: number
 *                         description: Prior probability hama
 *                       P_E:
 *                         type: number
 *                         description: Evidence probability
 *                       evidences:
 *                         type: array
 *                         items:
 *                           type: object
 *                           properties:
 *                             id_gejala:
 *                               type: integer
 *                             P_E_given_H:
 *                               type: number
 *                               description: Likelihood (nilai pakar gejala)
 *                       posterior_numerator:
 *                         type: number
 *                         description: Hasil perkalian P(E|H) * P(H)
 *                       posterior_probability:
 *                         type: number
 *                         description: P(H|E) - Hasil akhir teorema Bayes
 *                       probabilitas:
 *                         type: number
 *                         description: Nilai probabilitas untuk kompatibilitas
 *                 detail_perhitungan:
 *                   type: object
 *                   description: Informasi tentang metode perhitungan yang digunakan
 *                   properties:
 *                     keterangan:
 *                       type: string
 *                     formula:
 *                       type: object
 *                       properties:
 *                         P_H:
 *                           type: string
 *                         P_E_given_H:
 *                           type: string
 *                         P_E:
 *                           type: string
 *                         P_H_given_E:
 *                           type: string
 *       400:
 *         description: Permintaan tidak valid
 *       500:
 *         description: Terjadi kesalahan pada server
 */
router.post('/', roleMiddleware(['user', 'admin']), diagnosa);

module.exports = router;