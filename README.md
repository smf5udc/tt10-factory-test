![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout Medi-Minder

- [Read the documentation for project](docs/info.md)

## Objective and Motivation:

The medi-minder is a ASIC design for TinyTapeOut10 that tracks when medication is supposed to be taken and logs if that medication was taken. This project came to mind because of some struggles that I am currently facing. As a chronically ill person, I have to take multiple medications throughout the day. I find it hard to keep track of when to take my medications because they're constantly changing. I believe that integrating a chip of this design into a pill organizer/bottle could be successful and very useful for many.

## Introduction/Context:
optional section

## Implementation Details:
Top Module Medication Reminder
  1. Medication Database Logic: Stores a list of medications and their scheduled times
    - medications[0:15]: holds the scheduled "times" for each medication.
    - med_pointer: keeps track of how many medications the user has added
  2. Scheduler Logic: Keeps an internal clock, and constantly checks if it’s time to take a medica-
tion.
    - internal_clock increments on every clock cycle
    - Loops through all medications (medications[0..med_pointer-1]).
    - If internal_clock == medication[i], it raises a flag medication_due and remembers which
one (due_med_idx)
    - internal_clock: software clock counting up.
     - medication_due: 1 if a medication is due right now.
    - due_med_idx: which medication (index) is currently due
  3. Logger Logic - Every time a medication is due, save the event (time and which medication)
    - If medication_due == 1, it saves time, med_idx into log_memory.
    - log_pointer points to the next free log spot.
    - log_memory[0:15]: stores each event that happened, Upper 8 bits: time medication was
due and lower 8 bits stores which medication it was
    - log_pointer: points to next empty log slot.
  4. LCD Controller Logic - Shows log information on the output
    - It looks at log_memory[lcd_pointer] and sends part of it to the output.
    - toggle_view selects which part: Time of event or Medication ID
    - uio_in[0] (button) toggles the view, and after two toggles moves to the next log.
    - lcd_reg: holds the data to be sent to uo_out.
    - lcd_pointer: selects which log entry to display
    - toggle_view: switches between time view and medication ID view
    - ack_prev: remembers previous button state (for clean button press detection).
![alt text](https://github.com/smf5udc/tt10-med_test/blob/main/asic_project.png)
## Actions that need to be completed:


## References/Source files:
- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## What next?

- [Submit your design to the next shuttle](https://app.tinytapeout.com/).
- Edit [this README](README.md) and explain your design, how it works, and how to test it.
- Share your project on your social network of choice:
  - LinkedIn [#tinytapeout](https://www.linkedin.com/search/results/content/?keywords=%23tinytapeout) [@TinyTapeout](https://www.linkedin.com/company/100708654/)
  - Mastodon [#tinytapeout](https://chaos.social/tags/tinytapeout) [@matthewvenn](https://chaos.social/@matthewvenn)
  - X (formerly Twitter) [#tinytapeout](https://twitter.com/hashtag/tinytapeout) [@tinytapeout](https://twitter.com/tinytapeout)
