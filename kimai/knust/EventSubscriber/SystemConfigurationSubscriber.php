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

namespace KimaiPlugin\KnustBundle\EventSubscriber;

use App\Event\SystemConfigurationEvent;
use App\Form\Model\Configuration;
use App\Form\Model\SystemConfiguration as SystemConfigurationModel;
use KimaiPlugin\KnustBundle\Enum\Accent;
use KimaiPlugin\KnustBundle\Service\ThemeSettings;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\Form\Extension\Core\Type\ChoiceType;

/**
 * Section "Knust" under System > Settings.
 */
final class SystemConfigurationSubscriber implements EventSubscriberInterface
{
    public static function getSubscribedEvents(): array
    {
        return [
            SystemConfigurationEvent::class => ['onSystemConfiguration', 100],
        ];
    }

    public function onSystemConfiguration(SystemConfigurationEvent $event): void
    {
        $choices = [];
        foreach (Accent::cases() as $accent) {
            $choices['knust.accent.' . $accent->value] = $accent->value;
        }

        $event->addConfiguration(
            (new SystemConfigurationModel('knust'))
                ->setTranslation('knust.section')
                ->setTranslationDomain('messages')
                ->setConfiguration([
                    (new Configuration(ThemeSettings::KEY_ACCENT))
                        ->setLabel('knust.accent')
                        ->setTranslationDomain('messages')
                        ->setRequired(true)
                        ->setType(ChoiceType::class)
                        ->setValue(Accent::DEFAULT->value)
                        ->setOptions([
                            'choices' => $choices,
                            'choice_translation_domain' => 'messages',
                            'help' => 'knust.accent_help',
                        ]),
                ])
        );
    }
}
