<?php

/*
 * This file is part of the KnustBundle plugin for Kimai.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Copyright (C) 2026 Arian
 */

namespace KimaiPlugin\KnustBundle\Enum;

/**
 * Accent colour for primary buttons, links, focus and the active menu item.
 *
 * Tabler only accepts its own colour names for data-bs-theme-primary, so each
 * accent borrows one name. The stylesheet maps that name to the shrippen colour:
 *   blue -> --shr-blue, yellow -> --shr-yellow, orange -> --shr-orange, teal -> --shr-aqua
 */
enum Accent: string
{
    case BLUE = 'blue';
    case YELLOW = 'yellow';
    case ORANGE = 'orange';
    case AQUA = 'aqua';

    public const DEFAULT = self::BLUE;

    public function tablerName(): string
    {
        return match ($this) {
            self::AQUA => 'teal',
            default => $this->value,
        };
    }
}
