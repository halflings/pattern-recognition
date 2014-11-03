TRAINING_FACTOR = 0.5;
NUM_STATES = 8;

features = generateFeatures(raw);
hmms = runesHMMInit(features, NUM_STATES, TRAINING_FACTOR);

fullHP = 30;
HP = fullHP;

enemyFullHP = 100;
enemyHP = enemyFullHP;

poisoned = 0;

k = {'aam', 'morte', 'tera', 'vita', 'yok'};
while (enemyHP > 0 && HP > 0)

    fprintf('----------------------------------------------------------\n');
    fprintf('                                      \n');
    fprintf('######################################\n');
    fprintf('## HP: %i / %i                        \n', HP, fullHP);
    fprintf('## Enemy HP: %i / %i                  \n', enemyHP, enemyFullHP);
    fprintf('######################################\n');
    fprintf('                                      \n');

    if (poisoned)
        disp('  ! Your enemy is poisoned, he loses 2hp this turn)');
        enemyHP = enemyHP - 2;
    end
    
    % Attack by the enemy
    dmg = 1 + round(rand() * 4);
    fprintf('  # ENEMY TURN:\n');
    fprintf('  ! Your enemy attacks and inflicts %i damage.\n\n', dmg);
    HP =  HP - dmg;
    if (HP <= 0)
        break;
    end
    
    % Getting the casted runes
    rune1Id = guessRune(hmms);
    while (rune1Id == -1)
        fprintf('  ! Could not recognize the drawn rune, please repeat.\n');
        rune1Id = guessRune(hmms);
    end
    rune1 = cell2mat(k(rune1Id));
    
    fprintf('  # YOUR TURN:\n');
    fprintf('  . The first rune you cast is "%s"\n', rune1);
    
    rune2Id = guessRune(hmms);
    while (rune2Id == -1)
        fprintf('  ! Could not recognize the drawn rune, please repeat.\n');
        rune2Id = guessRune(hmms);
    end
    rune2 = cell2mat(k(rune2Id));

    fprintf('  . The second rune you cast is "%s"\n', rune2);
    
    if (strcmp(rune1, 'aam'))
        if (strcmp(rune2, 'vita'))
            disp('    - You launched a healing spell! 10HP restored.');
            HP = min([HP + 10, fullHP]);
            continue;
        end
        
        if (strcmp(rune2, 'morte'))
            disp('    - You poison your enemy! 2dmg inflicted per turn.');
            poisoned = 1;
            continue;
        end
        
        
        if (strcmp(rune2, 'yok'))
            disp('    - You launch a fireball on your enemy! 35dmg inflicted.');
            enemyHP = enemyHP - 35;
            continue;
        end
    end
    
    if (strcmp(rune1, 'morte'))
        if (strcmp(rune2, 'vita'))
            disp('    - You raise the death to fight for you! 10dmg inflicted to your enemy.');
            enemyHP = enemyHP - 10;
            continue;
        end
    end
    
    % no spell was recognized
    disp('    !! These runes do not form a spell. Better luck next time!');
end

if (enemyHP <= 0)
    disp('You triumphed and killed your enemy! (and won lots of XP, gold and course credits');
else
    disp('You were terrible at drawing things and doing sorcery, you lose!');
end
