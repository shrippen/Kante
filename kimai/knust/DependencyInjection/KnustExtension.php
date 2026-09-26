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

namespace KimaiPlugin\KnustBundle\DependencyInjection;

use Symfony\Component\Config\FileLocator;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Extension\PrependExtensionInterface;
use Symfony\Component\DependencyInjection\Loader;
use Symfony\Component\HttpKernel\DependencyInjection\Extension;

class KnustExtension extends Extension implements PrependExtensionInterface
{
    /**
     * Colour picker for customers, projects and activities: the shrippen palette instead of web colours.
     * Stays a default, admins can still change it under System > Settings.
     */
    private const COLOR_CHOICES = [
        'Blue|#83a598', 'Blue neutral|#458588',
        'Aqua|#8ec07c', 'Aqua neutral|#689d6a',
        'Green|#b8bb26', 'Green neutral|#98971a',
        'Yellow|#fabd2f', 'Yellow neutral|#d79921',
        'Orange|#fe8019', 'Orange neutral|#d65d0e',
        'Red|#fb4934', 'Red neutral|#cc241d',
        'Purple|#d3869b', 'Purple neutral|#b16286',
        'Cream|#e8dcc4', 'Grey|#a89984', 'Stone|#665c54',
    ];

    public function load(array $configs, ContainerBuilder $container): void
    {
        $loader = new Loader\YamlFileLoader($container, new FileLocator(__DIR__ . '/../Resources/config'));
        $loader->load('services.yaml');
    }

    public function prepend(ContainerBuilder $container): void
    {
        $container->prependExtensionConfig('kimai', [
            'theme' => [
                'color_choices' => implode(',', self::COLOR_CHOICES),
            ],
        ]);
    }
}
