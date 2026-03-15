# Hovr

Minimal macOS cursor switching, built in Swift.

## Overview

Hovr is a small menu bar macOS app that lets you swap the visible system cursor from a focused catalog of five designs.

This MVP uses emoji-based cursor prototypes to validate cursor replacement behavior before moving to graphic assets.

## What It Does

- Shows a clean main window with 5 cursor cards
- Adds a compact menu bar popover with the same 5 options
- Applies the selected cursor instantly
- Keeps the UI intentionally minimal and native to macOS

## Tech

- Swift
- SwiftUI
- AppKit for cursor overlay behavior
- No third-party dependencies

## Current Phase

Phase 1 is focused on testing cursor replacement with emoji cursors.

Once this interaction is confirmed, the next step is replacing the emoji overlay with PNG cursor assets.

## Run

Open `hovr.xcodeproj` in Xcode, choose the `hovr` scheme, select `My Mac`, and run with `Cmd+R`.

Because Hovr is configured as a menu bar app, it does not appear in the Dock.

## Status

Early MVP. Built for speed, clarity, and the smallest reasonable app footprint.
