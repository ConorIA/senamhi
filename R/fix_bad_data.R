.fix_bad_data <- function(bad_table, bad_row, label, type) {
  # First, let's see where this is happening.
  yearmon <- as.yearmon(bad_table$Fecha[bad_row])
  # Let's look at all months other than the bad month
  context <- filter(bad_table, !as.yearmon(Fecha) == yearmon & format(Fecha, format = "%m") == format(yearmon, format = "%m"))
  # Let's make sure we don't have other bad data
  context <- filter(context, var > -50 & var < 50)
  context <- unlist(context$var)
  # We should now have *fairly* clean context
  bad_data <- unlist(bad_table$var[bad_row])
  if (type == "dps") {
    if (!grepl("\\.", as.character(bad_data))) {
      # If this looks like a decimal error, let's salvage the data
      tdiff <- abs(mean(context, na.rm = TRUE) - (bad_data/10))
      if (length(tdiff) == 0) tdiff <- NA
      sdiff <- sd(context, na.rm = TRUE)
      prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
      if (!is.na(prop) && prop < 1.5) {
        observation <- paste0(label, " dps: ", bad_data, " -> ", bad_data/10, " (", round(prop, 2), ")")
        fix <- unlist(bad_data)/10
      } else {
        # Changed value not within two standard deviations.
        observation <- paste0(label, " err: ", bad_data, " -> NA (", round(prop, 2), ")")
        fix <- NA
      }
    } else {
      # We aren't sure that this is a decimal place shift!
      observation <- paste0(label, " err: ", bad_table$var[bad_row], " -> NA")
      fix <- NA
    }
  }
  if (type == "mme") {
    tdiff <- abs(mean(context, na.rm = TRUE) - (bad_data/10))
    if (length(tdiff) == 0) tdiff <- NA
    sdiff <- sd(context, na.rm = TRUE)
    prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
    if (!is.na(prop) && prop > 1.5) {
      # Let's see if it is a decimal place error (fairly conservative)
      tdiff <- abs(mean(context, na.rm = TRUE)-(bad_data*10))
      if (length(tdiff) == 0) tdiff <- NA
      prop <- if (!is.na(sdiff) & !is.na(tdiff)) (tdiff / sdiff) else NA
      if (!is.na(prop) && prop < 1.5) {
        observation <- paste0(label, " dps: ", bad_data, " -> ", 10 * bad_data, " (", round(prop, 2), ")")
        fix <- (10 * bad_data)
      } else {
        observation <- paste0(label, " err: ", bad_data, " -> NA (", round(prop, 2), ")")
        fix <- NA
      }
    } else {
      fix <- bad_data
      observation <- ''
    }
  }
  list(fix, observation)
}
