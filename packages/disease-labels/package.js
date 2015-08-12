Package.describe({
  name: 'tater:disease-labels',
  version: '0.0.1',
  summary: 'Models for tater',
  git: ''
});

Package.onUse(function(api) {
  api.addFiles('disease_labels.js', 'client');
  api.export(['DiseaseLabels'], ['client', 'server']);
});
