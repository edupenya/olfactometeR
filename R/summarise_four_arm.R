#' Summarise four-arm olfactometer experiment results
#' @name summarise_four_arm
#'
#' @description \code{summarise_four_arm} allows the user to summarise replicates
#' from four-arm olfactometer experiments.
#'
#' Upon executing \code{summarise_four_arm} the user will be prompted to select the
#' experiment replicates they want to summarise, displaying a summary table in the
#' console that can be exported as a .xlsx file if required.
#'
#' @usage summarise_four_arm()
#'
#' @return \code{summarise_four_arm} returns a summary table of the experiment
#' replicates to the console, which can be exported as a .xlsx file if required.
#'
#' @examples
#' \dontrun{
#' library(olfactometeR)
#' summarise_four_arm()
#'
#' Number of treatment arms (1/2): 2
#'
#'                    Four-arm olfactometer: two treatment arms w/ two treatments
#' -----------------------------------------------------------------------------------------------
#'               Time spent in zone (secs)                                    Mean      Std. Error
#'             -----------------------------------------------------------------------------------
#'   Replicate   Centre   Treatment 1   Treatment 2   Control 1   Control 2   Control    Control
#' -----------------------------------------------------------------------------------------------
#'       1       56.32       0.00          36.28        0.00        23.20      11.60      11.60
#'       2       35.81       0.00          22.46        0.00        5.86       2.93        2.93
#'       3       44.79       24.77         0.00         27.74       0.00       13.87      13.87
#' -----------------------------------------------------------------------------------------------
#'   Study species: Myzus persicae
#'   Treatment 1: Linalool
#'   Treatment 2: Limonene
#'
#' Save the ouput as an .xlsx file? (y/n) n
#' [1] "Output has not been saved"
#' }
#'
#' @export
#'
summarise_four_arm <- function() {
  treatment_arm_no <- readline("Number of treatment arms (1/2): ")

  if (treatment_arm_no == 1) {
    files <- tcltk::tk_choose.files(
      default = "*.txt",
      caption = "Select files",
      multi = TRUE,
      filters = NULL,
      index = 1
    )

    tbl <- files %>%
      purrr::map_df(~ readr::read_delim(
        .,
        delim = " ",
        col_names = c("A", "B", "C", "D", "E", "G", "H", "I"),
        col_types = readr::cols("H" = readr::col_integer())
      ))

    data <- tbl %>%
      tidyr::complete(tidyr::nesting(A, B, C, D, E, G), H = seq(1, 5, 1L)) %>%
      dplyr::arrange(is.na(I)) %>%
      dplyr::mutate(I = tidyr::replace_na(I, 0))

    zones <- data %>%
      dplyr::mutate(control = H != E) %>%
      dplyr::mutate(arms = H != D) %>%
      dplyr::arrange(B)

    centre_zone <- zones %>%
      dplyr::filter(arms == FALSE) %>%
      dplyr::group_by(B) %>%
      dplyr::summarise("Time" = sum(I)) %>%
      dplyr::mutate("Zone" = "Centre") %>%
      dplyr::rename("Replicate" = B)

    tbl_zero <- centre_zone %>%
      dplyr::select("Replicate", "Zone", "Time")

    treatment_zone <- zones %>%
      dplyr::filter(control == FALSE & arms == TRUE) %>%
      dplyr::group_by(B) %>%
      dplyr::summarise("Time" = sum(I)) %>%
      dplyr::mutate("Zone" = "Treatment") %>%
      dplyr::rename("Replicate" = B)

    tbl_one <- treatment_zone %>%
      dplyr::select("Replicate", "Zone", "Time")

    control_zones <- zones %>%
      dplyr::filter(control == TRUE & arms == TRUE) %>%
      dplyr::group_by(B, H) %>%
      dplyr::summarise("Time" = sum(I)) %>%
      dplyr::mutate("Control", 1:3) %>%
      dplyr::mutate("Zone" = paste0("Control", "_", 1:3)) %>%
      dplyr::rename("Replicate" = B)

    tbl_two <- control_zones %>%
      dplyr::select("Replicate", "Zone", "Time")

    control_mean <- control_zones %>%
      dplyr::group_by(Replicate) %>%
      dplyr::mutate("Control mean" = mean(Time)) %>%
      dplyr::mutate("Control SE" = sd(Time) / sqrt(length(Time)))

    tbl_three <- control_mean %>%
      dplyr::select("Replicate", "Control mean", "Control SE") %>%
      dplyr::distinct()

    tbl_four <- dplyr::bind_rows(tbl_zero, tbl_one, tbl_two)

    tbl_five <- tbl_four %>%
      tidyr::spread("Zone", "Time")

    tbl_six <- dplyr::bind_cols(tbl_five, tbl_three) %>%
      dplyr::select("Replicate", "Centre", "Treatment", "Control_1", "Control_2", "Control_3", "Control mean", "Control SE") %>%
      dplyr::rename("Control 1" = "Control_1", "Control 2" = "Control_2", "Control 3" = "Control_3", "Control" = "Control mean", "Control" = "Control SE")

    species_ID <- zones %>%
      dplyr::ungroup(B) %>%
      dplyr::select(C) %>%
      dplyr::distinct()

    treatment_ID <- zones %>%
      dplyr::ungroup(B) %>%
      dplyr::select(G) %>%
      dplyr::distinct()

    tbl_hux <- huxtable::as_hux(tbl_six, add_colnames = TRUE) %>%
      huxtable::theme_article(header_col = FALSE) %>%
      huxtable::set_caption(paste("Four-arm olfactometer: one treatment arm w/ one treatment")) %>%
      huxtable::set_caption_pos("topcenter") %>%
      huxtable::set_align("centre") %>%
      huxtable::insert_row(1, 1, 1, 1, 1, 1, 1, 1) %>%
      huxtable::merge_cells(1, 2:6) %>%
      huxtable::set_contents(2, 1, paste("Replicate")) %>%
      huxtable::set_contents(1, 1, paste(" ")) %>%
      huxtable::set_contents(1, 2, paste("Time spent in zone (secs)")) %>%
      huxtable::set_contents(1, 7, paste("Mean")) %>%
      huxtable::set_contents(1, 8, paste("Std. Error")) %>%
      huxtable::set_bottom_border(1, 1, 0) %>%
      huxtable::set_top_border(2, 1, 0) %>%
      huxtable::set_bottom_border(1, 7, 1) %>%
      huxtable::set_top_border(2, 7, 1) %>%
      huxtable::set_align(1, 2, "left") %>%
      huxtable::set_align(1, 7:8, "left") %>%
      huxtable::set_bold(1, 1, FALSE) %>%
      huxtable::set_bold(1, 2:8, FALSE) %>%
      huxtable::set_bold(2, 1:8, FALSE) %>%
      huxtable::add_footnote(paste("Study species:", species_ID)) %>%
      huxtable::add_footnote(paste("Treatment:", treatment_ID), border = 0)

    huxtable::number_format(tbl_hux)[-2, -1] <- 2

    huxtable::print_screen(tbl_hux, colnames = FALSE)

    file_export <- readline("Save the ouput as an .xlsx file? (y/n) ")

    if (file_export == "y") {
      file_path_name <- base::basename(tools::file_path_sans_ext(files))

      file_path_components <- readr::read_delim(file_path_name, delim = "_", col_names = c("A", "B", "C", "D", "E", "G", "H", "I")) %>%
        dplyr::select(A, B, C) %>%
        dplyr::distinct()

      user <- file_path_components %>%
        dplyr::select(A) %>%
        base::as.character()

      year <- file_path_components %>%
        dplyr::select(B) %>%
        base::as.character()

      experiment_no <- file_path_components %>%
        dplyr::select(C)

      huxtable::quick_xlsx(
        tbl_hux,
        file = paste(user, year, "Four_Arm_Experiment", experiment_no, "Summary.xlsx", sep = "_"),
        borders = 0.4,
        open = interactive()
      )
    } else if (file_export == "n") {
      base::print("Output has not been saved")
    }
  }

  if (treatment_arm_no == 2) {
    files <- tcltk::tk_choose.files(
      default = "*.txt",
      caption = "Select files",
      multi = TRUE,
      filters = NULL,
      index = 1
    )

    tbl <- files %>%
      purrr::map_df(~ readr::read_delim(
        .,
        delim = " ",
        col_names = c("A", "B", "C", "D", "E", "G", "H", "I", "J", "K"),
        col_types = readr::cols("J" = readr::col_integer())
      ))

    data <- tbl %>%
      tidyr::complete(tidyr::nesting(A, B, C, D, E, G, H, I), J = seq(1, 5, 1L)) %>%
      dplyr::arrange(is.na(K)) %>%
      dplyr::mutate(K = tidyr::replace_na(K, 0))

    zones <- data %>%
      dplyr::group_by(B) %>%
      dplyr::mutate(treatment = J %in% c(E, H)) %>%
      dplyr::mutate(treatment_one = J == E) %>%
      dplyr::mutate(treatment_two = J == H) %>%
      dplyr::mutate(arms = J != D) %>%
      dplyr::arrange(B)

    treatment_one_ID <- zones %>%
      dplyr::ungroup(B) %>%
      dplyr::select(G) %>%
      dplyr::distinct()

    treatment_two_ID <- zones %>%
      dplyr::ungroup(B) %>%
      dplyr::select(I) %>%
      dplyr::distinct()

    if (treatment_one_ID == treatment_two_ID) {
      centre_zone <- zones %>%
        dplyr::filter(arms == FALSE) %>%
        dplyr::group_by(B) %>%
        dplyr::mutate("Time" = sum(K)) %>%
        dplyr::mutate("Zone" = "Centre") %>%
        dplyr::rename("Replicate" = B)

      tbl_zero <- centre_zone %>%
        dplyr::select("Replicate", "Zone", "Time")

      treatment_zones <- zones %>%
        dplyr::filter(treatment == TRUE & arms == TRUE) %>%
        dplyr::group_by(B, J) %>%
        dplyr::summarise("Time" = sum(K)) %>%
        dplyr::mutate("Treatment", 1:2) %>%
        dplyr::mutate("Zone" = paste0("Treatment", "_", 1:2)) %>%
        dplyr::rename("Replicate" = B)

      tbl_one <- treatment_zones %>%
        dplyr::select("Replicate", "Zone", "Time")

      treatment_mean <- treatment_zones %>%
        dplyr::group_by(Replicate) %>%
        dplyr::mutate("Treatment mean" = mean(Time)) %>%
        dplyr::mutate("Treatment SE" = sd(Time) / sqrt(length(Time)))

      tbl_two <- treatment_mean %>%
        dplyr::select("Replicate", "Treatment mean", "Treatment SE") %>%
        dplyr::distinct()

      control_zones <- zones %>%
        dplyr::filter(treatment == FALSE & arms == TRUE) %>%
        dplyr::group_by(B, J) %>%
        dplyr::summarise("Time" = sum(K)) %>%
        dplyr::mutate("Control", 1:2) %>%
        dplyr::mutate("Zone" = paste0("Control", "_", 1:2)) %>%
        dplyr::rename("Replicate" = B)

      tbl_three <- control_zones %>%
        dplyr::select("Replicate", "Zone", "Time")

      control_mean <- control_zones %>%
        dplyr::group_by(Replicate) %>%
        dplyr::mutate("Control mean" = mean(Time)) %>%
        dplyr::mutate("Control SE" = sd(Time) / sqrt(length(Time)))

      tbl_four <- control_mean %>%
        dplyr::select("Replicate", "Control mean", "Control SE") %>%
        dplyr::distinct()

      tbl_five <- dplyr::bind_rows(tbl_zero, tbl_one, tbl_three) %>%
        dplyr::distinct()

      tbl_six <- tbl_five %>%
        tidyr::spread("Zone", "Time")

      tbl_seven <- dplyr::bind_cols(tbl_six, tbl_two, tbl_four) %>%
        dplyr::select("Replicate", "Centre", "Treatment_1", "Treatment_2", "Control_1", "Control_2", "Treatment mean", "Control mean", "Treatment SE", "Control SE") %>%
        dplyr::rename("Treatment 1" = "Treatment_1", "Treatment 2" = "Treatment_2", "Treatment" = "Treatment mean", "Control" = "Control mean", "Control 1" = "Control_1", "Control 2" = "Control_2", "Treatment" = "Treatment SE", "Control" = "Control SE")

      species_ID <- zones %>%
        dplyr::ungroup(B) %>%
        dplyr::select(C) %>%
        dplyr::distinct()

      tbl_hux <- huxtable::as_hux(tbl_seven, add_colnames = TRUE) %>%
        huxtable::theme_article(header_col = FALSE) %>%
        huxtable::set_caption(paste("Four-arm olfactometer: two treatment arms w/ one treatment")) %>%
        huxtable::set_caption_pos("topcenter") %>%
        huxtable::set_align("centre") %>%
        huxtable::insert_row(1, 1, 1, 1, 1, 1, 1, 1, 1, 1) %>%
        huxtable::merge_cells(1, 2:6) %>%
        huxtable::merge_cells(1, 7:8) %>%
        huxtable::merge_cells(1, 9:10) %>%
        huxtable::set_contents(1, 1, paste(" ")) %>%
        huxtable::set_contents(1, 2, paste("Time spent in zone (secs)")) %>%
        huxtable::set_contents(1, 7, paste("Mean")) %>%
        huxtable::set_contents(1, 9, paste("Std. Error")) %>%
        huxtable::set_bottom_border(1, 1, 0) %>%
        huxtable::set_top_border(2, 1, 0) %>%
        huxtable::set_bottom_border(1, 7, 1) %>%
        huxtable::set_top_border(2, 7, 1) %>%
        huxtable::set_bottom_border(1, 9, 1) %>%
        huxtable::set_top_border(2, 9, 1) %>%
        huxtable::set_align(1, 2, "left") %>%
        huxtable::set_align(1, 7, "left") %>%
        huxtable::set_align(1, 9, "left") %>%
        huxtable::set_bold(1, 1, FALSE) %>%
        huxtable::set_bold(1, 2:10, FALSE) %>%
        huxtable::set_bold(2, 1:10, FALSE) %>%
        huxtable::add_footnote(paste("Study species:", species_ID)) %>%
        huxtable::add_footnote(paste("Treatment 1:", treatment_one_ID), border = 0) %>%
        huxtable::add_footnote(paste("Treatment 2:", treatment_two_ID), border = 0)

      huxtable::number_format(tbl_hux)[-2, -1] <- 2

      huxtable::print_screen(tbl_hux, colnames = FALSE)

      file_export <- readline("Save the ouput as an .xlsx file? (y/n) ")

      if (file_export == "y") {
        file_path_name <- base::basename(tools::file_path_sans_ext(files))

        file_path_components <- readr::read_delim(file_path_name, delim = "_", col_names = c("A", "B", "C", "D", "E", "G", "H", "I")) %>%
          dplyr::select(A, B, C) %>%
          dplyr::distinct()

        user <- file_path_components %>%
          dplyr::select(A) %>%
          base::as.character()

        year <- file_path_components %>%
          dplyr::select(B) %>%
          base::as.character()

        experiment_no <- file_path_components %>%
          dplyr::select(C)

        huxtable::quick_xlsx(
          tbl_hux,
          file = paste(user, year, "Four_Arm_Experiment", experiment_no, "Summary.xlsx", sep = "_"),
          borders = 0.4,
          open = interactive()
        )
      } else if (file_export == "n") {
        base::print("Output has not been saved")
      }
    }

    if (treatment_one_ID != treatment_two_ID) {
      centre_zone <- zones %>%
        dplyr::filter(arms == FALSE) %>%
        dplyr::group_by(B) %>%
        dplyr::mutate("Time" = sum(K)) %>%
        dplyr::mutate("Zone" = "Centre") %>%
        dplyr::rename("Replicate" = B)

      tbl_zero <- centre_zone %>%
        dplyr::select("Replicate", "Zone", "Time")

      treatment_one <- zones %>%
        dplyr::filter(treatment_one == TRUE) %>%
        dplyr::group_by(B) %>%
        dplyr::summarise("Time" = sum(K)) %>%
        dplyr::mutate("Zone" = "Treatment 1") %>%
        dplyr::rename("Replicate" = B)

      tbl_one <- treatment_one %>%
        dplyr::select("Replicate", "Zone", "Time")

      treatment_two <- zones %>%
        dplyr::filter(treatment_two == TRUE) %>%
        dplyr::group_by(B) %>%
        dplyr::summarise("Time" = sum(K)) %>%
        dplyr::mutate("Zone" = "Treatment 2") %>%
        dplyr::rename("Replicate" = B)

      tbl_two <- treatment_two %>%
        dplyr::select("Replicate", "Zone", "Time")

      control_zones <- zones %>%
        dplyr::filter(treatment == FALSE & arms == TRUE) %>%
        dplyr::group_by(B, J) %>%
        dplyr::summarise("Time" = sum(K)) %>%
        dplyr::mutate("Control", 1:2) %>%
        dplyr::mutate("Zone" = paste0("Control", "_", 1:2)) %>%
        dplyr::rename("Replicate" = B)

      tbl_three <- control_zones %>%
        dplyr::select("Replicate", "Zone", "Time")

      control_mean <- control_zones %>%
        dplyr::group_by(Replicate) %>%
        dplyr::mutate("Control mean" = mean(Time)) %>%
        dplyr::mutate("Control SE" = sd(Time) / sqrt(length(Time)))

      tbl_four <- control_mean %>%
        dplyr::select("Replicate", "Control mean", "Control SE") %>%
        dplyr::distinct()

      tbl_five <- dplyr::bind_rows(tbl_zero, tbl_one, tbl_two, tbl_three) %>%
        dplyr::distinct()

      tbl_six <- tbl_five %>%
        tidyr::spread("Zone", "Time")

      tbl_seven <- dplyr::bind_cols(tbl_six, tbl_four) %>%
        dplyr::select("Replicate", "Centre", "Treatment 1", "Treatment 2", "Control_1", "Control_2", "Control mean", "Control SE") %>%
        dplyr::rename("Control 1" = "Control_1", "Control 2" = "Control_2", "Control" = "Control mean", "Control" = "Control SE")

      species_ID <- zones %>%
        dplyr::ungroup(B) %>%
        dplyr::select(C) %>%
        dplyr::distinct()

      tbl_hux <- huxtable::as_hux(tbl_seven, add_colnames = TRUE) %>%
        huxtable::theme_article(header_col = FALSE) %>%
        huxtable::set_caption(paste("Four-arm olfactometer: two treatment arms w/ two treatments")) %>%
        huxtable::set_caption_pos("topcenter") %>%
        huxtable::set_align("centre") %>%
        huxtable::insert_row(1, 1, 1, 1, 1, 1, 1, 1) %>%
        huxtable::merge_cells(1, 2:6) %>%
        huxtable::set_contents(2, 1, paste("Replicate")) %>%
        huxtable::set_contents(1, 1, paste(" ")) %>%
        huxtable::set_contents(1, 2, paste("Time spent in zone (secs)")) %>%
        huxtable::set_contents(1, 7, paste("Mean")) %>%
        huxtable::set_contents(1, 8, paste("Std. Error")) %>%
        huxtable::set_bottom_border(1, 1, 0) %>%
        huxtable::set_top_border(2, 1, 0) %>%
        huxtable::set_bottom_border(1, 7, 1) %>%
        huxtable::set_top_border(2, 7, 1) %>%
        huxtable::set_align(1, 2, "left") %>%
        huxtable::set_align(1, 7:8, "left") %>%
        huxtable::set_bold(1, 1, FALSE) %>%
        huxtable::set_bold(1, 2:8, FALSE) %>%
        huxtable::set_bold(2, 1:8, FALSE) %>%
        huxtable::add_footnote(paste("Study species:", species_ID)) %>%
        huxtable::add_footnote(paste("Treatment 1:", treatment_one_ID), border = 0) %>%
        huxtable::add_footnote(paste("Treatment 2:", treatment_two_ID), border = 0)

      huxtable::number_format(tbl_hux)[-2, -1] <- 2

      huxtable::print_screen(tbl_hux, colnames = FALSE)

      file_export <- readline("Save the ouput as an .xlsx file? (y/n) ")

      if (file_export == "y") {
        file_path_name <- base::basename(tools::file_path_sans_ext(files))

        file_path_components <- readr::read_delim(file_path_name, delim = "_", col_names = c("A", "B", "C", "D", "E", "G", "H", "I")) %>%
          dplyr::select(A, B, C) %>%
          dplyr::distinct()

        user <- file_path_components %>%
          dplyr::select(A) %>%
          base::as.character()

        year <- file_path_components %>%
          dplyr::select(B) %>%
          base::as.character()

        experiment_no <- file_path_components %>%
          dplyr::select(C)

        huxtable::quick_xlsx(
          tbl_hux,
          file = paste(user, year, "Four_Arm_Experiment", experiment_no, "Summary.xlsx", sep = "_"),
          borders = 0.4,
          open = interactive()
        )
      } else if (file_export == "n") {
        base::print("Output has not been saved")
      }
    }
  }
}
