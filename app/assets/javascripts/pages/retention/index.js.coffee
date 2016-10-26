#= require pages/app/base

window.App ||= {}

class App.RetentionIndex extends App.AppBase
  constructor: (@retentionNumbers, @startDate) ->
    super()
    @startDate = new Date(@startDate)

  run: ->
    self = @
    $(document).ready ->
      container = document.getElementById('retention')

      Cornelius.draw
        initialDate: self.startDate
        container: container
        cohort: self.retentionNumbers
        title: 'Weekly Retention (Last 8 Weeks)'
        timeInterval: 'weekly'

