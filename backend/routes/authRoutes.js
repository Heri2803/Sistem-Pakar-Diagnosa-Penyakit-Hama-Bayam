const express = require('express');
const router = express.Router();
const authController = require('../controller/authController');

/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: API untuk autentikasi pengguna
 */

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Membuat akun baru
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *               
 *             properties:
 *               name:
 *                 type: string
 *                 example: John Doe
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *               alamat:
 *                 type: string
 *                 example: "london inggris"
 *     responses:
 *       201:
 *         description: Akun berhasil dibuat
 *       400:
 *         description: Email sudah digunakan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/register', authController.register);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login ke akun
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *               password:
 *                 type: string
 *                 example: mypassword
 *     responses:
 *       200:
 *         description: Login berhasil
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Login berhasil
 *                 token:
 *                   type: string
 *                   example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
 *                 role:
 *                   type: string
 *                   example: user
 *                 userId:
 *                   type: integer
 *                   example: 1
 *       401:
 *         description: Email atau password salah
 *       403:
 *         description: Akun sedang digunakan di perangkat lain
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Akun ini sedang digunakan di perangkat lain.
 *                 debug:
 *                   type: string
 *                   example: User 1 masih dalam sesi aktif
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/login', authController.login);

/**
 * @swagger
 * /api/auth/logout:
 *   post:
 *     summary: Logout dari akun
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               userId:
 *                 type: integer
 *                 description: ID user (opsional, diambil dari token jika tidak disediakan)
 *                 example: 1
 *     responses:
 *       200:
 *         description: Logout berhasil
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Logout berhasil
 *                 userId:
 *                   type: integer
 *                   example: 1
 *       400:
 *         description: Tidak ada sesi login aktif
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Tidak ada sesi login aktif
 *                 userId:
 *                   type: integer
 *                   example: 1
 *                 activeSessions:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example: ["2", "3"]
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/logout', authController.logout);

/**
 * @swagger
 * /api/auth/debug-sessions:
 *   get:
 *     summary: Debug - Lihat semua sesi aktif (HAPUS DI PRODUCTION!)
 *     tags: [Debug]
 *     responses:
 *       200:
 *         description: Informasi debug sesi
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 activeSessions:
 *                   type: object
 *                   description: Objek berisi semua sesi aktif
 *                   example: 
 *                     "1": 
 *                       loginTime: "2024-01-01T10:00:00.000Z"
 *                       email: "johndoe@gmail.com"
 *                 sessionTimeouts:
 *                   type: array
 *                   items:
 *                     type: string
 *                   description: Array ID user yang memiliki timeout aktif
 *                   example: ["1", "2"]
 *                 message:
 *                   type: string
 *                   example: Debug info - hapus endpoint ini di production
 */
router.get('/debug-sessions', authController.debugSessions);

/**
 * @swagger
 * /api/auth/force-logout:
 *   post:
 *     summary: Debug - Force logout user tertentu (HAPUS DI PRODUCTION!)
 *     tags: [Debug]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *             properties:
 *               userId:
 *                 type: integer
 *                 description: ID user yang akan di-force logout
 *                 example: 1
 *     responses:
 *       200:
 *         description: Force logout berhasil
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: User 1 berhasil di-force logout
 *       404:
 *         description: User tidak ditemukan dalam sesi aktif
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: User tidak ditemukan dalam sesi aktif
 */
router.post('/force-logout', authController.forceLogout);

/**
 * @swagger
 * /api/auth/clear-all-sessions:
 *   post:
 *     summary: Debug - Bersihkan semua sesi aktif (HAPUS DI PRODUCTION!)
 *     tags: [Debug]
 *     responses:
 *       200:
 *         description: Semua sesi berhasil dibersihkan
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Semua sesi aktif berhasil dibersihkan
 *                 clearedSessions:
 *                   type: integer
 *                   example: 3
 */
router.post('/clear-all-sessions', authController.clearAllSessions);

/**
 * @swagger
 * /api/auth/send-reset-code:
 *   post:
 *     summary: Mengirim kode verifikasi ke email pengguna
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 example: johndoe@gmail.com
 *     responses:
 *       200:
 *         description: Kode verifikasi telah dikirim ke email
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Kode verifikasi telah dikirim ke email Anda.
 *                 expiresIn:
 *                   type: string
 *                   example: 10 minutes
 *       400:
 *         description: Email tidak valid
 *       404:
 *         description: User tidak ditemukan
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/send-reset-code', authController.sendResetCodeWithGmail);

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     summary: Reset password menggunakan kode verifikasi
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *               - password
 *             properties:
 *               code:
 *                 type: string
 *                 example: "123456"
 *               password:
 *                 type: string
 *                 example: newpassword123
 *     responses:
 *       200:
 *         description: Password berhasil direset
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Password berhasil direset
 *                 success:
 *                   type: boolean
 *                   example: true
 *       400:
 *         description: Kode tidak valid atau password tidak memenuhi syarat
 *       500:
 *         description: Terjadi kesalahan server
 */
router.post('/reset-password', authController.resetPasswordWithCode);

module.exports = router;
