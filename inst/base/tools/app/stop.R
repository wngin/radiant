#######################################
# Stop menu
#######################################
observeEvent(input$stop_radiant, {
  if (r_local) stop_radiant()
})

stop_radiant <- function() {
  ## quit R, unless you are running an interactive session
  if (interactive()) {
    ## flush input and r_data into Rgui or Rstudio
    isolate({
      reactiveValuesToList(input) %>%
        {.$nav_radiant <- r_data$nav_radiant; .} %>%
        assign("r_state", ., envir = .GlobalEnv)

      assign("r_data", reactiveValuesToList(r_data), envir = .GlobalEnv)

      stop_message <- "\nStopping Radiant. State available as 'r_state' and 'r_data'.\n"

      if (!is_empty(input$rmd_report)) {

        "```{r echo = FALSE}\n# knitr::opts_chunk$set(comment=NA, cache=FALSE, message=FALSE, warning=FALSE)\n# suppressMessages(library(radiant))\n# uncomment the lines above to 'knit' the Rmd file in Rstudio\n# you will also need to load the data using load()\n```\n\n" %>%
          paste0(.,input$rmd_report) -> rmd_report
        os_type <- Sys.info()["sysname"]
        if (os_type == 'Windows') {
          cat(rmd_report, file = "clipboard")
          stop_message %<>% paste0(., "Report content was copied to the clipboard.\n")
        } else if (os_type == "Darwin") {
          out <- pipe("pbcopy")
          cat(rmd_report, file = out)
          close(out)
          stop_message %<>% paste0(., "Report content was copied to the clipboard.\n")
        } else if (os_type == "Linux") {
        }
      }
      ## removing r_env and r_sessions
      if (exists("r_sessions")) rm(r_sessions, envir = .GlobalEnv)
      unlink("~/r_figures/", recursive = TRUE)
      sshhr(try(rm(js_head, nav_ui, r_encoding, r_functions, r_help, r_local, r_path, r_pkgs, shared_ui, withMathJax, envir = .GlobalEnv), silent = TRUE))
      cat(stop_message)
      stopApp("-- Stopped Radiant --")
    })
  } else {
    stopApp("-- Stopped Radiant --")
    q("no")
  }
}
