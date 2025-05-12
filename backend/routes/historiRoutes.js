const express = require('express');
const router = express.Router();
const { getAllHistori, getHistoriByUserId } = require('../controller/historiController');

/**
 * @swagger
 * /api/histori:
 *   get:
 *     summary: Ambil semua data histori
 *     tags:
 *       - Histori
 *     responses:
 *       200:
 *         description: Berhasil mengambil data histori
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Data Histori
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       userId:
 *                         type: integer
 *                         example: 2
 *                       hasil:
 *                         type: float
 *                         example: 0.85
 *                       tanggal_diagnosa:
 *                         type: string
 *                         format: date-time
 *                         example: 2025-05-12T10:00:00Z
 *       500:
 *         description: Terjadi kesalahan server
 */
router.get('/', getAllHistori);

/**
 * @swagger
 * /api/histori/user/{userId}:
 *   get:
 *     summary: Ambil data histori berdasarkan ID user
 *     tags:
 *       - Histori
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         description: ID user untuk mengambil histori
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Berhasil mengambil data histori user
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Data Histori User
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       userId:
 *                         type: integer
 *                         example: 1
 *                       hasil:
 *                         type: float
 *                         example: 0.85
 *                       tanggal_diagnosa:
 *                         type: string
 *                         format: date-time
 *                         example: 2025-05-12T10:00:00Z
 *       404:
 *         description: Tidak ada histori untuk user ini
 *       500:
 *         description: Terjadi kesalahan server
 */
router.get('/user/:userId', getHistoriByUserId);

module.exports = router;