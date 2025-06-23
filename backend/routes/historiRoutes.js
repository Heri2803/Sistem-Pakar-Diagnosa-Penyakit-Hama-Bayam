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

/**
 * @swagger
 * /api/histori/delete:
 *   delete:
 *     tags:
 *       - Histori
 *     summary: Hapus histori berdasarkan user ID dan tanggal diagnosa
 *     description: Menghapus histori diagnosa berdasarkan ID user dan tanggal diagnosa yang spesifik
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_id
 *               - tanggal_diagnosa
 *             properties:
 *               user_id:
 *                 type: string
 *                 description: ID user yang akan dihapus historinya
 *                 example: "123"
 *               tanggal_diagnosa:
 *                 type: string
 *                 format: date-time
 *                 description: Tanggal diagnosa yang akan dihapus (format YYYY-MM-DD HH:mm:ss)
 *                 example: "2024-01-15 10:30:00"
 *           example:
 *             user_id: "123"
 *             tanggal_diagnosa: "2024-01-15 10:30:00"
 *     responses:
 *       200:
 *         description: Histori berhasil dihapus
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   description: Pesan sukses
 *                 data:
 *                   type: object
 *                   properties:
 *                     deleted_count:
 *                       type: integer
 *                       description: Jumlah record yang dihapus
 *                     user_id:
 *                       type: string
 *                       description: ID user
 *                     tanggal_diagnosa:
 *                       type: string
 *                       description: Tanggal diagnosa yang dihapus
 *             example:
 *               message: "Histori berhasil dihapus"
 *               data:
 *                 deleted_count: 3
 *                 user_id: "123"
 *                 tanggal_diagnosa: "2024-01-15 10:30:00"
 *       400:
 *         description: Bad Request - Parameter tidak valid
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *             examples:
 *               invalid_user_id:
 *                 summary: User ID tidak valid
 *                 value:
 *                   message: "User ID tidak valid"
 *               missing_date:
 *                 summary: Tanggal diagnosa kosong
 *                 value:
 *                   message: "Tanggal diagnosa tidak boleh kosong"
 *       404:
 *         description: Not Found - Histori tidak ditemukan
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *             example:
 *               message: "Histori tidak ditemukan untuk user dan tanggal yang dimaksud"
 *       500:
 *         description: Internal Server Error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 error:
 *                   type: string
 *             example:
 *               message: "Terjadi kesalahan server"
 *               error: "Database connection failed"
 */
router.delete('/histori/delete', deleteHistoriByUserAndDate);

/**
 * @swagger
 * /api/histori/{historiId}:
 *   delete:
 *     tags:
 *       - Histori
 *     summary: Hapus histori berdasarkan ID histori
 *     description: Menghapus histori diagnosa berdasarkan ID histori yang spesifik
 *     parameters:
 *       - in: path
 *         name: historiId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID histori yang akan dihapus
 *         example: "456"
 *     responses:
 *       200:
 *         description: Histori berhasil dihapus
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Histori berhasil dihapus"
 *                 data:
 *                   type: object
 *                   properties:
 *                     deleted_id:
 *                       type: string
 *                       example: "456"
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.delete('/histori/:historiId', deleteHistoriById);

/**
 * @swagger
 * /api/histori/user/{userId}/all:
 *   delete:
 *     tags:
 *       - Histori
 *     summary: Hapus semua histori user
 *     description: Menghapus semua histori diagnosa untuk user tertentu
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID user yang akan dihapus semua historinya
 *         example: "123"
 *     responses:
 *       200:
 *         description: Semua histori user berhasil dihapus
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Semua histori user berhasil dihapus"
 *                 data:
 *                   type: object
 *                   properties:
 *                     deleted_count:
 *                       type: integer
 *                       example: 15
 *                     user_id:
 *                       type: string
 *                       example: "123"
 *       400:
 *         $ref: '#/components/responses/BadRequest'
 *       404:
 *         $ref: '#/components/responses/NotFound'
 *       500:
 *         $ref: '#/components/responses/InternalServerError'
 */
router.delete('/histori/user/:userId/all', deleteAllHistoriByUserId);

module.exports = router;