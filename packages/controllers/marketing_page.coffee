if Meteor.isClient
  Template.marketingPage.onCreated ->
    $('head').append('<meta name="description" content="Tater is an easy to use annotation web application that enables users to code, analyze, and export text with project-specific codes." /><meta name="keywords" content="qualitative data,annotation,research,interviews" />');
