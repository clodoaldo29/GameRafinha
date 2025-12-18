/**************************************************************************
Top-Down Shooter 2D – MVP em GML
Cada bloco abaixo representa o código de um evento específico.
**************************************************************************/

/* obj_game ----------------------------------------------------------------*/
/*** Create Event ***/
global.player_hp = 5;
global.score = 0;
global.game_over = false;

if (!instance_exists(obj_player)) {
    instance_create_layer(room_width * 0.5, room_height * 0.5, "Instances", obj_player);
}

if (!instance_exists(obj_spawner)) {
    instance_create_layer(room_width * 0.5, room_height * 0.5, "Instances", obj_spawner);
}

/*** Step Event ***/
if (global.player_hp <= 0) {
    global.game_over = true;
}

if (global.game_over && keyboard_check_pressed(ord("R"))) {
    restart_room();
}

/*** Draw GUI Event ***/
var hp_text = "HP: " + string(global.player_hp);
var score_text = "Score: " + string(global.score);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(16, 16, hp_text);
draw_text(16, 40, score_text);

if (global.game_over) {
    var msg = "GAME OVER - Pressione R para reiniciar";
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(display_get_gui_width() * 0.5, display_get_gui_height() * 0.5, msg);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


/* obj_player --------------------------------------------------------------*/
/*** Create Event ***/
move_speed = 4;
fire_cooldown_max = 8;
fire_cooldown = 0;
invuln_timer = 0;
image_angle = 0;

/*** Step Event ***/
if (fire_cooldown > 0) fire_cooldown--;
if (invuln_timer > 0) invuln_timer--;

var mx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var my = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var len = point_distance(0, 0, mx, my);

if (len > 0) {
    mx /= len;
    my /= len;
}

var hsp = mx * move_speed;
var vsp = my * move_speed;

if (place_meeting(x + hsp, y, obj_wall)) {
    move_contact_solid((hsp > 0) ? 0 : 180, abs(hsp));
    hsp = 0;
} else {
    x += hsp;
}

if (place_meeting(x, y + vsp, obj_wall)) {
    move_contact_solid((vsp < 0) ? 90 : 270, abs(vsp));
    vsp = 0;
} else {
    y += vsp;
}

image_angle = point_direction(x, y, mouse_x, mouse_y);

if (mouse_check_button(mb_left) && fire_cooldown <= 0 && !global.game_over) {
    var spawn_x = x + lengthdir_x(16, image_angle);
    var spawn_y = y + lengthdir_y(16, image_angle);
    var b = instance_create_layer(spawn_x, spawn_y, "Instances", obj_bullet_player);
    b.direction = image_angle;
    b.image_angle = image_angle;
    b.owner = id;
    fire_cooldown = fire_cooldown_max;
}

if (invuln_timer <= 0) {
    var hit_enemy = instance_place(x, y, obj_enemy);
    if (hit_enemy != noone) {
        global.player_hp -= hit_enemy.contact_damage;
        invuln_timer = room_speed div 2;
    }
}

if (global.player_hp <= 0) {
    global.game_over = true;
}

/*** Draw Event ***/
draw_self();


/* obj_enemy ---------------------------------------------------------------*/
/*** Create Event ***/
move_speed = 2;
hp = 3;
contact_damage = 1;

/*** Step Event ***/
if (!global.game_over && instance_exists(obj_player)) {
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    var hsp_enemy = lengthdir_x(move_speed, dir);
    var vsp_enemy = lengthdir_y(move_speed, dir);

    if (place_meeting(x + hsp_enemy, y, obj_wall)) {
        move_contact_solid((hsp_enemy > 0) ? 0 : 180, abs(hsp_enemy));
        hsp_enemy = 0;
    } else {
        x += hsp_enemy;
    }

    if (place_meeting(x, y + vsp_enemy, obj_wall)) {
        move_contact_solid((vsp_enemy < 0) ? 90 : 270, abs(vsp_enemy));
        vsp_enemy = 0;
    } else {
        y += vsp_enemy;
    }
}

var hit_bullet = instance_place(x, y, obj_bullet_player);
if (hit_bullet != noone) {
    hp -= hit_bullet.damage;
    with (hit_bullet) instance_destroy();
}

if (hp <= 0) {
    global.score += 10;
    instance_destroy();
}


/* obj_bullet_player -------------------------------------------------------*/
/*** Create Event ***/
speed = 12;
damage = 1;
image_angle = direction;

/*** Step Event ***/
x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);

if (place_meeting(x, y, obj_wall)) {
    instance_destroy();
    exit;
}

var hit_enemy_bullet = instance_place(x, y, obj_enemy);
if (hit_enemy_bullet != noone) {
    with (hit_enemy_bullet) {
        hp -= other.damage;
    }
    instance_destroy();
    exit;
}

if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
}


/* obj_wall ----------------------------------------------------------------*/
/*** Create Event ***/
solid = true;


/* obj_spawner -------------------------------------------------------------*/
/*** Create Event ***/
max_enemies = 10;
spawn_interval = room_speed;
spawn_timer = spawn_interval;
spawn_margin = 48;

/*** Step Event ***/
if (global.game_over) exit;

spawn_timer--;

if (spawn_timer <= 0 && instance_number(obj_enemy) < max_enemies) {
    repeat (25) {
        var px = irandom_range(spawn_margin, room_width - spawn_margin);
        var py = irandom_range(spawn_margin, room_height - spawn_margin);

        if (!place_meeting(px, py, obj_wall)) {
            instance_create_layer(px, py, "Instances", obj_enemy);
            break;
        }
    }

    spawn_timer = spawn_interval;
}
