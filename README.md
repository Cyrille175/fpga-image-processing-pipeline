# FPGA Image Processing Pipeline

## Overview

This project implements a real-time image processing pipeline in VHDL on FPGA.

The design builds a 3x3 sliding window from an input pixel stream and applies a spatial filter to the image. The architecture is modular and separates window generation, line buffering, and filtering operations.

The project also includes simulation files and testbenches to validate the behavior of the system on grayscale image data.

## Project Objectives

The main objective of this project is to design a hardware architecture capable of processing image streams in real time.

More specifically, the project aims to:
- receive a grayscale pixel stream,
- reconstruct a valid 3x3 neighborhood around each pixel,
- apply a 2D filter on this neighborhood,
- generate a filtered output stream,
- validate the complete chain through simulation.

## Architecture

The system is organized into several modules.

The first part is a memory and buffering stage. It stores previous image lines and reconstructs the 3x3 sliding window required for spatial filtering.

The second part is the filtering stage. It receives the 3x3 window and computes the filtered output pixel.

The complete architecture is based on a pipelined dataflow approach. Each clock cycle advances the data through the processing chain.

The main modules of the project are:
- `memoire_cache.vhd`: generation of the 3x3 window from the input stream,
- `ligne_retard.vhd`: local delay registers used to align pixels,
- `generic_DFF.vhd`: generic register building block,
- `filtre_2D.vhd`: 2D filter implementation,
- `filtre_flou.vhd`: blur filter implementation,
- `tb_image_flou.vhd`: testbench for image filtering,
- `image_gaussien.vhd`: simulation chain for Gaussian-style filtering.

## Design Principles

The project follows a modular approach in which each block has a clear role.

The memory stage is responsible for temporal and spatial alignment of pixels.

The filtering stage is responsible only for arithmetic processing.

The testbench is responsible for reading input image data from a file and writing filtered results to an output file.

This separation makes the design easier to understand, validate, and improve.

## Technical Content

The architecture relies on:
- synchronous VHDL design,
- pipelined processing,
- line buffering,
- sliding-window generation,
- fixed-width arithmetic on image pixels,
- simulation-based validation with file I/O.

## Current Status

The project already contains:
- a dedicated memory module for 3x3 window generation,
- a blur filter module,
- a 2D filter module,
- a complete image-based simulation flow using input and output data files.

## Strengths of the Project

This project is technically interesting because it demonstrates:
- hardware-oriented image processing,
- modular FPGA design,
- dataflow reasoning,
- management of temporal alignment between pixels,
- separation between buffering and computation.

## Possible Improvements

Several improvements can make the project stronger and more professional.

First, the repository structure can be cleaned by separating source files, testbenches, and documentation into dedicated folders.

Second, the filters can be generalized with coefficients or generics so that the same architecture supports multiple kernels.

Third, the control logic can be simplified and made more portable by reducing dependence on vendor-specific FIFO components.

Fourth, a valid output signal should be added at the filter output to make pipeline latency explicit and easier to reuse in a larger system.

Fifth, the documentation can be improved with a block diagram, timing explanation, and simulation results.

## What I Learned

This project allowed me to work on:
- FPGA-oriented architecture design,
- real-time image processing constraints,
- pipelined hardware design,
- memory organization for sliding-window generation,
- simulation and validation of a complete processing chain.

## Conclusion

This project is a good foundation for real-time FPGA image processing.

It demonstrates the design of a modular hardware pipeline that reconstructs image neighborhoods and applies spatial filtering on streamed pixel data.

With additional cleanup, parameterization, and documentation, it can become a strong portfolio project for embedded systems, digital design, and hardware acceleration roles.








# FPGA Image Processing Pipeline

## Présentation

Ce projet implémente en VHDL sur FPGA une chaîne de traitement d’image en temps réel.

L’architecture construit une fenêtre glissante 3x3 à partir d’un flux de pixels en entrée, puis applique un filtre spatial sur l’image. La conception est modulaire et sépare la génération de la fenêtre, le tamponnement des lignes et le calcul du filtre.

Le projet contient également des fichiers de simulation et des testbenches permettant de valider le fonctionnement du système sur une image en niveaux de gris.

## Objectifs du projet

L’objectif principal de ce projet est de concevoir une architecture matérielle capable de traiter un flux d’image en temps réel.

Plus précisément, le projet vise à :
- recevoir un flux de pixels en niveaux de gris,
- reconstruire un voisinage 3x3 valide autour de chaque pixel,
- appliquer un filtre 2D sur ce voisinage,
- produire un flux de sortie filtré,
- valider l’ensemble de la chaîne par simulation.

## Architecture

Le système est organisé en plusieurs modules.

La première partie correspond à l’étage mémoire et tamponnement. Elle conserve les lignes précédentes de l’image et reconstruit la fenêtre glissante 3x3 nécessaire au filtrage spatial.

La deuxième partie correspond à l’étage de filtrage. Il reçoit la fenêtre 3x3 et calcule le pixel filtré en sortie.

L’architecture complète repose sur une approche de type pipeline. À chaque cycle d’horloge, les données progressent à travers la chaîne de traitement.

Les principaux modules du projet sont :
- `memoire_cache.vhd` : génération de la fenêtre 3x3 à partir du flux d’entrée,
- `ligne_retard.vhd` : registres de retard locaux utilisés pour aligner les pixels,
- `generic_DFF.vhd` : bloc de registre générique,
- `filtre_2D.vhd` : implémentation d’un filtre 2D,
- `filtre_flou.vhd` : implémentation d’un filtre de flou,
- `tb_image_flou.vhd` : testbench de filtrage d’image,
- `image_gaussien.vhd` : chaîne de simulation pour un filtrage de type gaussien.

## Principes de conception

Le projet suit une approche modulaire dans laquelle chaque bloc a un rôle clair.

L’étage mémoire est responsable de l’alignement temporel et spatial des pixels.

L’étage de filtrage est responsable uniquement du traitement arithmétique.

Le testbench est responsable de la lecture des données image depuis un fichier et de l’écriture des résultats filtrés dans un fichier de sortie.

Cette séparation rend le design plus lisible, plus facile à valider et plus simple à faire évoluer.

## Contenu technique

L’architecture s’appuie sur :
- une conception VHDL synchrone,
- un traitement pipeliné,
- des tampons de ligne,
- une génération de fenêtre glissante,
- une arithmétique sur largeur fixe adaptée aux pixels,
- une validation par simulation avec lecture et écriture de fichiers.

## État actuel du projet

Le projet contient déjà :
- un module mémoire dédié à la génération de fenêtres 3x3,
- un module de filtre flou,
- un module de filtre 2D,
- une chaîne complète de simulation sur image avec fichiers d’entrée et de sortie.

## Points forts du projet

Ce projet est techniquement intéressant car il montre :
- du traitement d’image orienté matériel,
- une conception FPGA modulaire,
- un raisonnement en flux de données,
- la gestion de l’alignement temporel entre pixels,
- une séparation claire entre tamponnement et calcul.

## Améliorations possibles

Plusieurs améliorations peuvent rendre ce projet plus solide et plus professionnel.

D’abord, la structure du dépôt peut être nettoyée en séparant les sources, les testbenches et la documentation dans des dossiers dédiés.

Ensuite, les filtres peuvent être généralisés à l’aide de coefficients ou de génériques afin que la même architecture puisse supporter plusieurs noyaux.

Il serait également utile de simplifier la logique de contrôle et de réduire la dépendance à des composants FIFO spécifiques à un fournisseur, afin de rendre le projet plus portable.

Un signal de validité en sortie du filtre devrait aussi être ajouté pour rendre explicite la latence du pipeline et faciliter la réutilisation du bloc dans un système plus large.

Enfin, la documentation peut être enrichie avec un schéma de blocs, une explication du timing et des résultats de simulation.

## Ce que j’ai appris

Ce projet m’a permis de travailler sur :
- la conception d’architectures orientées FPGA,
- les contraintes du traitement d’image en temps réel,
- la conception matérielle pipelinée,
- l’organisation mémoire pour la génération de fenêtres glissantes,
- la simulation et la validation d’une chaîne complète de traitement.

## Conclusion

Ce projet constitue une bonne base pour du traitement d’image temps réel sur FPGA.

Il montre la conception d’une chaîne matérielle modulaire capable de reconstruire des voisinages d’image et d’appliquer un filtrage spatial sur un flux de pixels.

Avec un nettoyage supplémentaire, une meilleure paramétrisation et une documentation plus poussée, il peut devenir un très bon projet vitrine pour des postes en systèmes embarqués, conception numérique et accélération matérielle.
