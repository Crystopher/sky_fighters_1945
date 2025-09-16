extends Node

func plane_explosion():
	if $PlaneExplosion.playing:
		$PlaneExplosion.stop()
	$PlaneExplosion.play()

func plane_hit():
	if $PlaneHit.playing:
		$PlaneHit.stop()
	$PlaneHit.play()

func enemy_railgun_fire():
	if $EnemyRailgunFire.playing:
		$EnemyRailgunFire.stop()
	$EnemyRailgunFire.play()

func enemy_three_globular():
	if $EnemyThreeGlobular.playing:
		$EnemyThreeGlobular.stop()
	$EnemyThreeGlobular.play()

func weapon_railgun():
	if $WeaponRailgun.playing:
		$WeaponRailgun.stop()
	$WeaponRailgun.play()

func weapon_thunder():
	if $WeaponThunder.playing:
		$WeaponThunder.stop()
	$WeaponThunder.play()
