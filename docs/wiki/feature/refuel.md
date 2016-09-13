---
layout: wiki
title: Refuel
description: Adds the option to refuel vehicles.
group: feature
category: interaction
parent: wiki
mod: ace
version:
  major: 3
  minor: 4
  patch: 0
---

## 1. Overview

This adds the option to refuel vehicles. The basic concept of refuel a vehicle is similar to reality. You need to interact with the fuel source (i.e. fuel truck, gas pump, ...), the fuel nozzle and the vehicle you want to refuel.

## 2. Usage

### 2.1 Start refueling vehicles
- Interact with the fuel truck <kbd>⊞&nbsp;Win</kbd> (ACE3 default key bind `Interact Key`).
- Select `Take fuel nozzle`. Your character will holster his weapon and receive a fuel nozzle.
- Walk to the vehicle you want to refuel and interact with it.
- Select `Connect fuel nozzle`.
- Place the nozzle on the vehicle and interact with it.
- Select `Start fueling`. The vehicle is now being refuel.

Refueling takes some time which depends on its fuel tank size, the vehicle type and the module settings.

### 2.2 Returning the nozzle
- Interact with the nozzle <kbd>⊞&nbsp;Win</kbd> (ACE3 default key bind `Interact Key`).
- Select `Stop fueling` if refueling is still under way.
- Select `Take fuel nozzle` which is only possible after stopping. Your character will holster his weapon and pick up the fuel nozzle.
- Walk to the fuel truck and interact with it.
- Select `Return fuel nozzle`.

### 2.3 Checking the remaining fuel
- Interact with the fuel truck <kbd>⊞&nbsp;Win</kbd> (ACE3 default key bind `Interact Key`).
- Select `Check remaining fuel`.
- A hint will display the remaining fuel in liters.

### 2.4 Checking the fuel counter
- Interact with the fuel truck <kbd>⊞&nbsp;Win</kbd> (ACE3 default key bind `Interact Key`).
- Select `Check fuel counter`.
- A hint will display the fueled amount in liters.

## 3. FAQ

### Can I drop the nozzle?
Yes, using the action menu.

### Can I pick up a nozzle?
Yes, using the interact menu <kbd>⊞&nbsp;Win</kbd> (ACE3 default key bind `Interact Key`).

### The nozzle was dropped. What's wrong?
You can only use the nozzle within a close distance from its source. You may need to park closer.

### The engine of the fuel truck is broken. Why?
While refueling, you can't move the fuel truck. Return the nozzle.

### How do I replenish the fuel supply on a fuel truck?
Please check the framework description for more details.

### Something broke, I can't use the fuel truck / nozzle any longer. What to do?
You can reset the fuel truck and its nozzle by calling `ace_refuel_fnc_reset` with its first parameter being the fuel truck object.

## 4. Dependencies

{% include dependencies_list.md component="refuel" %}
