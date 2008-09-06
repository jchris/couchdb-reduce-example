function(doc) {
  if (doc.sensor && doc.description) emit(doc.sensor, doc.description);
};