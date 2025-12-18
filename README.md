# GameRafinha

MVP de Top-Down Shooter em 2D para GameMaker Studio 2 (GML).

## Objetos e eventos

O arquivo [`gml/top_down_shooter_mvp.gml`](gml/top_down_shooter_mvp.gml) contém o código de cada evento para:

- `obj_game`: inicialização geral, gerenciamento de HUD (HP/Score) e Game Over com reinício em **R**.
- `obj_player`: movimento com **WASD**, mira no mouse, tiro com botão esquerdo, colisão sólida em eixos separados e invulnerabilidade curta após dano.
- `obj_enemy`: perseguição ao jogador, colisão sólida e dano por contato.
- `obj_bullet_player`: projétil do jogador, colisão com paredes e inimigos.
- `obj_wall`: parede sólida.
- `obj_spawner`: gera inimigos até um limite definido.

Cole cada bloco no evento correspondente no GameMaker Studio 2 para montar o projeto jogável.
