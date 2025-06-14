const BabysitterRequest = require('../models/BabysitterRequest');

exports.createRequest = async (parentId, data) => {
  return await BabysitterRequest.create({ ...data, parent_id: parentId });
};

exports.getRequestsByParent = async (parentId) => {
  return await BabysitterRequest.find({ parent_id: parentId });
};
