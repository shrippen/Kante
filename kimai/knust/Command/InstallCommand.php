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

namespace KimaiPlugin\KnustBundle\Command;

use App\Command\AbstractBundleInstallerCommand;

/**
 * bin/console kimai:bundle:knust:install
 * Copies Resources/public (CSS, fonts) to public/bundles/knust/.
 */
class InstallCommand extends AbstractBundleInstallerCommand
{
    protected function getBundleCommandNamePart(): string
    {
        return 'knust';
    }

    protected function hasAssets(): bool
    {
        return true;
    }
}
