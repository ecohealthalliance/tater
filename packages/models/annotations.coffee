Annotations = new Mongo.Collection('annotations')
Annotation = Astro.Class
  name: 'Annotation'
  collection: Annotations
  transform: true
  fields:
    documentId: 'string'
    userId: 'string'
    keyword: 'string'
    startIndex: 'number'
    endIndex: 'number'
