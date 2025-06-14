const express = require('express');
const router = express.Router();
const controller = require('../controllers/babysitterRequestController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, controller.createRequest);
router.get('/my', authMiddleware, controller.getMyRequests);
router.delete('/:id', authMiddleware, controller.deleteRequest);
router.get('/by-parent/:parentId', controller.getRequestByParentId);

module.exports = router;
