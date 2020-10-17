#
# Install: Include this code into an aircraft to make it damagable. (remember to add it to the -set file)
#          for damage to be recognised, the property /payload/armament/msg must be 1
#
# Authors: Nikolai V. Chr., Pinto and Richard (with improvement by Onox)
#
#


############################ Config ######################################################################################
var full_damage_dist_m = 3;# Can vary from aircraft to aircraft depending on how many failure modes it has.
                           # Many modes (like Viggen) ought to have lower number like zero.
                           # Few modes (like F-14) ought to have larger number such as 3.
                           # For assets this should be average radius of the asset.
var use_hitpoints_instead_of_failure_modes_bool = 0;# mainly used by assets that don't have failure modes.
var hp_max = 80;# given a direct hit, how much pounds of warhead is needed to kill. Only used if hitpoints is enabled.
var hitable_by_air_munitions = 1;   # if anti-air can do damage
var hitable_by_cannon = 1;          # if cannon can do damage
#var hitable_by_ground_munitions = 1;# if anti-ground/marine can do damage
var is_fleet = 0;  # Is really 7 ships, 3 of which has offensive missiles.
##########################################################################################################################

var clamp = func(v, min, max) { v < min ? min : v > max ? max : v }

var TRUE  = 1;
var FALSE = 0;

var shells = {
    # [id,damage,(name)]
    #
    # 0.20 means a direct hit will disable 20% of the failure modes on average.
    # or, 0.20 also means a direct hit can do 20 hitpoints damage.
    #
    "M70 rocket":        [0,0.250], #135mm
    "S-5 rocket":        [1,0.200], # 55mm
    "M55 cannon shell":  [2,0.100], # 30mm
    "KCA cannon shell":  [3,0.100], # 30mm
    "GSh-30":            [4,0.100], # 30mm
    "GAU-8/A":           [5,0.100], # 30mm
    "Mk3Z":              [6,0.100], # 30mm Jaguar
    "BK27 cannon":       [7,0.070], # 27mm
    "GSh-23":            [8,0.065], # 23mm
    "M61A1 shell":       [9,0.050], # 20mm
    "50 BMG":            [10,0.015], # 12.7mm (non-explosive)    
    "7.62":              [11,0.005], # 7.62mm (non-explosive)
    "Hydra-70":          [12,0.250], # F-16
    "SNEB":              [13,0.250], # Jaguar   
};    

# lbs of warheads is explosive+fragmentation+fuse, so total warhead mass.

var warheads = {
    # [id,lbs,anti surface,cluster,(name)]
    "AGM-65":            [0,  126.00,1,0],
    "AGM-84":            [1,  488.00,1,0],
    "AGM-88":            [2,  146.00,1,0],
    "AGM65":             [3,  200.00,1,0],
    "AGM-119":           [4,  264.50,1,0],
    "AGM-154A":          [5,  493.00,1,0],
    "AGM-158":           [6, 1000.00,1,0],
    "ALARM":             [7,  450.00,1,0],
    "AM39-Exocet":       [8,  364.00,1,0], 
    "AS-37-Martel":      [9,  330.00,1,0], 
    "AS30L":             [10,  529.00,1,0],
    "BL755":             [11,  100.00,1,1],# 800lb bomblet warhead. Mix of armour piecing and HE. 100 due to need to be able to kill buk-m2.    
    "CBU-87":            [12,  100.00,1,1],# bomblet warhead. Mix of armour piecing and HE. 100 due to need to be able to kill buk-m2.    
    "CBU-105":           [13,  100.00,1,1],# bomblet warhead. Mix of armour piecing and HE. 100 due to need to be able to kill buk-m2.    
    "Exocet":            [14,  364.00,1,0],
    "FAB-100":           [15,   92.59,1,0],
    "FAB-250":           [16,  202.85,1,0],
    "FAB-500":           [17,  564.38,1,0],
    "GBU-12":            [18,  190.00,1,0],
    "GBU-24":            [19,  945.00,1,0],
    "GBU-31":            [20,  945.00,1,0],
    "GBU-54":            [21,  190.00,1,0],
    "GBU12":             [22,  190.00,1,0],
    "GBU16":             [23,  450.00,1,0],
    "HVAR":              [24,    7.50,1,0],#P51
    "KAB-500":           [25,  564.38,1,0],
    "Kh-25MP":           [26,  197.53,1,0],
    "Kh-66":             [27,  244.71,1,0],
    "LAU-68":            [28,   10.00,1,0],
    "M71":               [29,  200.00,1,0],
    "M71R":              [30,  200.00,1,0],
    "M90":               [31,   10.00,1,1],# bomblet warhead. x3 of real mass.
    "MK-82":             [32,  192.00,1,0],
    "MK-83":             [33,  445.00,1,0],
    "MK-83HD":           [34,  445.00,1,0],
    "MK-84":             [35,  945.00,1,0],
    "OFAB-100":          [36,   92.59,1,0],
    "RB-04E":            [37,  661.00,1,0],
    "RB-15F":            [38,  440.92,1,0],
    "RB-75":             [39,  126.00,1,0],
    "RN-14T":            [40,  800.00,1,0], #fictional, thermobaeric replacement for the RN-24 nuclear bomb
    "RN-18T":            [41, 1200.00,1,0], #fictional, thermobaeric replacement for the RN-28 nuclear bomb
    "RS-2US":            [42,   28.66,1,0],
    "S-21":              [43,  245.00,1,0],
    "S-24":              [44,  271.00,1,0],
    "SCALP":             [45,  992.00,1,0],
    "Sea Eagle":         [46,  505.00,1,0],
    "SeaEagle":          [47,  505.00,1,0],
    "STORMSHADOW":       [48,  850.00,1,0],
    "ZB-250":            [49,  236.99,1,0],
    "ZB-500":            [50,  473.99,1,0],
    "aim-120":           [51,   44.00,0,0],
    "AIM-120":           [52,   44.00,0,0],
    "AIM-54":            [53,  135.00,0,0],
    "aim-7":             [54,   88.00,0,0],
    "AIM-7":             [55,   88.00,0,0],
    "aim-9":             [56,   20.80,0,0],
    "AIM-9":             [57,   20.80,0,0],
    "AIM120":            [58,   44.00,0,0],
    "AIM132":            [59,   22.05,0,0],
    "AIM9":              [60,   20.80,0,0],
    "KN-06":             [61,  315.00,0,0],
    "M317":              [62,  145.00,0,0],
    "Magic-2":           [63,   27.00,0,0], 
    "Majic":             [64,   26.45,0,0],
    "Matra MICA":        [65,   30.00,0,0],
    "Matra R550 Magic 2":[66,   27.00,0,0],
    "MATRA-R530":        [67,   55.00,0,0],
    "MatraMica":         [68,   30.00,0,0],
    "MatraMicaIR":       [69,   30.00,0,0],
    "MatraR550Magic2":   [70,   27.00,0,0],
    "Meteor":            [71,   55.00,0,0],
    "MICA-EM":           [72,   30.00,0,0], 
    "MICA-IR":           [73,   30.00,0,0], 
    "R-13M":             [74,   16.31,0,0],
    "R-27R1":            [75,   85.98,0,0],
    "R-27T1":            [76,   85.98,0,0],
    "R-3R":              [77,   16.31,0,0],
    "R-3S":              [78,   16.31,0,0],
    "R-55":              [79,   20.06,0,0],
    "R-60":              [80,    6.60,0,0],
    "R-60M":             [81,    7.70,0,0],
    "R-73E":             [82,   16.31,0,0],
    "R-77":              [83,   49.60,0,0],
    "R74":               [84,   16.00,0,0],
    "RB-05A":            [85,  353.00,1,0],
    "RB-24":             [86,   20.80,0,0],
    "RB-24J":            [87,   20.80,0,0],
    "RB-71":             [88,   88.00,0,0],
    "RB-74":             [89,   20.80,0,0],
    "RB-99":             [90,   44.00,0,0],
    "S530D":             [91,   66.00,0,0],
    "S48N6":             [92,  330.00,0,0],# 48N6 from S-300pmu
    "pilot":             [93,    0.00,1,0],# ejected pilot
};

var id2warhead = [];
var launched = {};# callsign: elapsed-sec
var approached = {};# callsign: uniqueID

var k = keys(warheads);

for(var myid = 0;myid<size(k);myid+=1) {
  foreach(key ; k) {
    var wh = warheads[key];
    if (wh[0] == myid) {
      append(wh, key);
      append(id2warhead, wh);
      break;
    }
  }
  if (size(id2warhead) != myid+1) {
    printf("warheads corrupt at %d", myid);
    return;
  }
}

var id2shell = [];

var k = keys(shells);

for(var myid = 0;myid<size(k);myid+=1) {
  foreach(key ; k) {
    var wh = shells[key];
    if (wh[0] == myid) {
      append(wh, key);
      append(id2shell, wh);
      break;
    }
  }
  if (size(id2shell) != myid+1) {
    printf("shells corrupt at %d", myid);
    return;
  }
}

#
# Create emesary recipient for handling other craft's missile positioins.
var DamageRecipient =
{
    new: func(_ident)
    {
        var new_class = emesary.Recipient.new(_ident);

        new_class.Receive = func(notification)
        {
#
#
# This will be where movement and damage notifications are received. 
# This can replace MP chat for damage notifications 
# and allow missile visibility globally (i.e. all suitable equipped models) have the possibility
# to receive notifications from all other suitably equipped models.
            if (notification.NotificationType == "ArmamentInFlightNotification") {
#                print("recv(d1): ",notification.NotificationType, " ", notification.Ident, 
#                      " UniqueIdentity=",notification.UniqueIdentity,
#                      " Kind=",notification.Kind,
#                      " SecondaryKind=",notification.SecondaryKind,
#                      " lat=",notification.Position.lat(),
#                      " lon=",notification.Position.lon(),
#                      " alt=",notification.Position.alt(),
#                      " u_fps=",notification.u_fps,
#                      " Heading=",notification.Heading,
#                      " Pitch=",notification.Pitch,
#                      " IsDistinct=",notification.IsDistinct,
#                      " Callsign=",notification.Callsign,
#                      " RemoteCallsign=",notification.RemoteCallsign,
#                      " Flags=",notification.Flags,
#                      " Radar=",bits.test(notification.Flags, 0),
#                      " Thrust=",bits.test(notification.Flags, 1));
                #
                # todo:
                #   animate missiles
                #
                if(getprop("payload/armament/msg") == 0) {
                  return emesary.Transmitter.ReceiptStatus_NotProcessed;
                }
                if (notification.Kind == 3) {
                  return emesary.Transmitter.ReceiptStatus_OK;
                }
                if (notification.SecondaryKind-21 == 93) {
                  # ejection seat
                  return emesary.Transmitter.ReceiptStatus_OK;
                }
                # craters now use their own notifiction
                #if (notification.SecondaryKind == 200) {
                #  if (notification.RemoteCallsign == "1" and getprop("payload/armament/enable-craters") == 1) {
                #    var crater_model = getprop("payload/armament/models") ~ "crater_small.xml";
                #    geo.put_model(crater_model, notification.Position.lat(), notification.Position.lon(), notification.Position.alt());
                #  } elsif (notification.RemoteCallsign == "2" and getprop("payload/armament/enable-craters") == 1) {
                #    var crater_model = getprop("payload/armament/models") ~ "crater_big.xml";
                #    geo.put_model(crater_model, notification.Position.lat(), notification.Position.lon(), notification.Position.alt());
                #  }
                #  return emesary.Transmitter.ReceiptStatus_OK;
                #}
                
                
                
                var elapsed = getprop("sim/time/elapsed-sec");
                var ownPos = geo.aircraft_position();
                var bearing = ownPos.course_to(notification.Position);
                var radarOn = bits.test(notification.Flags, 0);
                var thrustOn = bits.test(notification.Flags, 1);
                
                
                
                # Missile launch warning:
                if (thrustOn) {
                  var launch = launched[notification.Callsign~notification.UniqueIdentity];
                  if (launch == nil or elapsed - launch > 300) {
                    launch = elapsed;
                    launched[notification.Callsign~notification.UniqueIdentity] = launch;
                    if (notification.Position.direct_distance_to(ownPos)*M2NM < 5) {
                      setprop("payload/armament/MLW-bearing", bearing);
                      setprop("payload/armament/MLW-launcher", notification.Callsign);
                      setprop("payload/armament/MLW-count", getprop("payload/armament/MLW-count")+1);
                      var out = sprintf("Missile Launch Warning from %03d degrees.", bearing);
                      screen.log.write(out, 1,1,0);# temporary till someone models a RWR in RIO seat
                      print(out);
                      damageLog.push(sprintf("Missile Launch Warning from %03d degrees from %s.", bearing, notification.Callsign));
                    }
                  }
                }
                
                # Missile approach warning:
                var callsign = getprop("sim/multiplay/callsign");
                callsign = size(callsign) < 8 ? callsign : left(callsign,7);
                if (notification.RemoteCallsign != callsign) return emesary.Transmitter.ReceiptStatus_OK;
                if (!radarOn) return emesary.Transmitter.ReceiptStatus_OK;# this should be little more complex later
                var heading = getprop("orientation/heading-deg");
                var clock = geo.normdeg(bearing - heading);
                setprop("payload/armament/MAW-bearing", bearing);
                setprop("payload/armament/MAW-active", 1);# resets every 1 seconds
                MAW_elapsed = elapsed;
                printf("Missile Approach Warning from %03d degrees.", bearing);
                var appr = approached[notification.Callsign~notification.UniqueIdentity];
                if (appr == nil or elapsed - appr > 450) {
                  damageLog.push(sprintf("Missile Approach Warning from %03d degrees from %s.", bearing, notification.Callsign));
                  screen.log.write(sprintf("Missile Approach Warning from %03d degrees.", bearing), 1,1,0);# temporary till someone models a RWR in RIO seat
                  approached[notification.Callsign~notification.UniqueIdentity] = elapsed;
                }
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            if (notification.NotificationType == "ArmamentNotification") {
#                if (notification.FromIncomingBridge) {
#                    print("recv(d2): ",notification.NotificationType, " ", notification.Ident,
#                          " Kind=",notification.Kind,
#                          " SecondaryKind=",notification.SecondaryKind,
#                          " RelativeAltitude=",notification.RelativeAltitude,
#                          " Distance=",notification.Distance,
#                          " Bearing=",notification.Bearing,
#                          " Inc-bridge=",notification.FromIncomingBridge,
#                          " RemoteCallsign=",notification.RemoteCallsign);
#                    debug.dump(notification);
                    #
                    #
                    var callsign = getprop("sim/multiplay/callsign");
                    callsign = size(callsign) < 8 ? callsign : left(callsign,7);
                    if (notification.RemoteCallsign == callsign and getprop("payload/armament/msg") == 1) {
                        #damage enabled and were getting hit
                        if (notification.SecondaryKind > 110 and hitable_by_cannon) {
                            # cannon hit
                            var probability = id2shell[notification.SecondaryKind - 111][1];
                            var typ = id2shell[notification.SecondaryKind - 111][2];
                            var hit_count = notification.Distance;
                            if (hit_count != nil) {
                                var damaged_sys = 0;
                                for (var i = 1; i <= hit_count; i = i + 1) {
                                  var failed = fail_systems(probability);
                                  damaged_sys = damaged_sys + failed;
                                }
                                printf("Took %.1f%% x %2d damage from %s! %s systems was hit.", probability*100, hit_count, typ, damaged_sys);
                                damageLog.push(sprintf("%d %s impact from %s.", hit_count, typ, notification.Callsign));
                                nearby_explosion();
                            }
                        } elsif (notification.SecondaryKind > 20) {
                            # its a warhead
                            var dist     = notification.Distance;
                            var wh = id2warhead[notification.SecondaryKind - 21];
                            var type = wh[4];#test code
                            damageLog.push(sprintf("%s impact at %.1f meters from %s.", type, dist, notification.Callsign));
                            if (wh[3] == 1) {
                                # cluster munition
                                var lbs = wh[1];
                                var maxDist = maxDamageDistFromWarhead(lbs);
                                var distance = math.max(0,rand()*5-full_damage_dist_m);#being 0 to 5 meters from a bomblet on average.
                                var diff = math.max(0, maxDist-distance);
                                diff = diff * diff;
                                var probability = diff / (maxDist*maxDist);
                                if (use_hitpoints_instead_of_failure_modes_bool) {
                                  var hpDist = maxDamageDistFromWarhead(hp_max);
                                  probability = (maxDist/hpDist)*probability;
                                }
                                var failed = fail_systems(probability, hp_max);
                                var percent = 100 * probability;
                                printf("Took %.1f%% damage from %s clusterbomb at %0.1f meters from bomblet. %s systems was hit", percent,type,distance,failed);
                                nearby_explosion();
                                return;
                            }

                            var distance = math.max(dist-full_damage_dist_m, 0);
              
                            var maxDist = 0;# distance where the explosion dont hurt us anymore
                            var lbs = 0;
                            
                            if (wh[2] == 0) {
                              lbs = wh[1];
                              maxDist = maxDamageDistFromWarhead(lbs);#3*sqrt(lbs)
                            } elsif (hitable_by_air_munitions and wh[2] == 1) {
                              lbs = wh[1];
                              maxDist = maxDamageDistFromWarhead(lbs);
                            } else {
                              return;
                            }
                            
                            var diff = maxDist-distance;
                            if (diff < 0) {
                              diff = 0;
                            }
                            diff = diff * diff;
                                          
                            var probability = diff / (maxDist*maxDist);
                            
                            if (use_hitpoints_instead_of_failure_modes_bool) {
                              var hpDist = maxDamageDistFromWarhead(hp_max);
                              probability = (maxDist/hpDist)*probability;
                            }

                            var failed = fail_systems(probability, hp_max);
                            var percent = 100 * probability;
                            printf("Took %.1f%% damage from %s missile at %0.1f meters. %s systems was hit", percent,type,dist,failed);
                            nearby_explosion();
                            
                            ####
                            # I don't remember all the considerations that went into our original warhead damage model.
                            # But looking at the formula it looks like they all do 100% damage at 0 meter hit,
                            # and warhead size is only used to determine the decrease of damage with distance increase.
                            # It sorta gets the job done though, so I am hesitant to advocate that warheads above a certain
                            # size should give 100% damage for some distance, and that warheads smaller than certain size should
                            # not give 100% damage even on direct hit.
                            # Anyway, for hitpoint based assets, this is now the case. Maybe we should consider to also do something
                            # similar for failure mode based aircraft. ~Nikolai
                            ####
                            
                            ## example 1: ##
                            # 300 lbs warhead, 50 meters distance
                            # maxDist=52
                            # diff = 52-50 = 2
                            # diff^2 = 4
                            # prob = 4/2700 = 0.15%
                            
                            ## example 2: ##
                            # 300 lbs warhead, 25 meters distance
                            # maxDist=52
                            # diff = 52-25 = 27
                            # diff^2 = 729
                            # prob = 729/2700 = 27%
                        } 
                    }
#                }
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            if (notification.NotificationType == "StaticNotification") {
                if(getprop("payload/armament/msg") == 0) {
                  return emesary.Transmitter.ReceiptStatus_NotProcessed;
                }
                if (notification.Kind == CREATE and getprop("payload/armament/enable-craters") == 1 and statics["obj_"~notification.UniqueIdentity] == nil) {
                    if (notification.SecondaryKind == 0) {# TODO: make a hash with all the models
                        var crater_model = getprop("payload/armament/models") ~ "crater_small.xml";
                        var static = geo.put_model(crater_model, notification.Position.lat(), notification.Position.lon(), notification.Position.alt(), notification.Heading);
                        if (static != nil) {
                            statics["obj_"~notification.UniqueIdentity] = [static, notification.Position.lat(), notification.Position.lon(), notification.Position.alt(), notification.Heading];
                            #static is a PropertyNode inside /models
                        }
                    } elsif (notification.SecondaryKind == 1) {
                        var crater_model = getprop("payload/armament/models") ~ "crater_big.xml";
                        var static = geo.put_model(crater_model, notification.Position.lat(), notification.Position.lon(), notification.Position.alt(), notification.Heading);
                        if (static != nil) {
                            statics["obj_"~notification.UniqueIdentity] = [static, notification.Position.lat(), notification.Position.lon(), notification.Position.alt(), notification.Heading];
                        }
                    }
                }
                return emesary.Transmitter.ReceiptStatus_OK;
            }
            return emesary.Transmitter.ReceiptStatus_NotProcessed;
        };
        return new_class;
    }
};

# Static variables for notification.Kind:
var CREATE = 1;
var MOVE = 2;
var DESTROY = 3;
var IMPACT = 3;

var statics = {};

damage_recipient = DamageRecipient.new("DamageRecipient");
emesary.GlobalTransmitter.Register(damage_recipient);

var maxDamageDistFromWarhead = func (lbs) {
  # very simple
  var dist = 3*math.sqrt(lbs);

  return dist;
}

var fail_systems = func (probability, factor = 100) {#this factor needs tuning after all asset hitpoints have been evaluated.
    if (is_fleet) {
      return fail_fleet_systems(probability, factor);
    } elsif (use_hitpoints_instead_of_failure_modes_bool) {
      hp -= factor * probability*(0.75+rand()*0.25);# from 75 to 100% damage
      printf("HP: %d/%d", hp, hp_max);
      setprop("sam/damage", math.max(0,100*hp/hp_max));#used in HUD
      if ( hp < 0 ) {
        setprop("/carrier/sunk/",1);#we are dead
        setprop("/sim/multiplay/generic/int[2]",1);#radar off
        setprop("/sim/multiplay/generic/int[0]",1);#smoke on
        setprop("/sim/messages/copilot", getprop("sim/multiplay/callsign")~" dead.");
      }
      return -1;
    } else {
      var failure_modes = FailureMgr._failmgr.failure_modes;
      var mode_list = keys(failure_modes);
      var failed = 0;
      foreach(var failure_mode_id; mode_list) {
        #print(failure_mode_id);
          if (rand() < probability) {
              FailureMgr.set_failure_level(failure_mode_id, 1);
              failed += 1;
              if (failure_mode_id == "Engines/engine" and yasim_list == nil and getprop("sim/flight-model") == "yasim") {
                # fail  yasim:
                setprop("sim/model/uh1/state",0);
                setprop("controls/engines/engine/magnetos", 0);
                setprop("controls/engines/engine/cutoff", 1);
                setprop("controls/engines/engine/on-fire", 1);
                #set a listener so that if a restart is attempted, it'll fail.
                yasim_list = setlistener("sim/model/uh1/state",func {setprop("sim/model/uh1/state",0);});
                yasim_list2 = setlistener("controls/engines/engine/cutoff",func {setprop("controls/engines/engine/cutoff",1);});
              }
              if (failure_mode_id == "Engines/engine[1]" and yasim_list3 == nil and getprop("sim/flight-model") == "yasim") {
                # fail  yasim:
                setprop("controls/engines/engine[1]/magnetos", 0);
                setprop("controls/engines/engine[1]/cutoff", 1);
                setprop("controls/engines/engine[1]/on-fire", 1);
                #set a listener so that if a restart is attempted, it'll fail.
                yasim_list3 = setlistener("controls/engines/engine[1]/cutoff",func {setprop("controls/engines/engine[1]/cutoff",1);});
              }
              if (failure_mode_id == "Engines/engine[2]" and yasim_list4 == nil and getprop("sim/flight-model") == "yasim") {
                # fail  yasim:
                setprop("controls/engines/engine[2]/magnetos", 0);
                setprop("controls/engines/engine[2]/cutoff", 1);
                setprop("controls/engines/engine[2]/on-fire", 1);
                #set a listener so that if a restart is attempted, it'll fail.
                yasim_list4 = setlistener("controls/engines/engine[2]/cutoff",func {setprop("controls/engines/engine[2]/cutoff",1);});
              }
              if (failure_mode_id == "Engines/engine[3]" and yasim_list5 == nil and getprop("sim/flight-model") == "yasim") {
                # fail  yasim:
                setprop("controls/engines/engine[3]/magnetos", 0);
                setprop("controls/engines/engine[3]/cutoff", 1);
                setprop("controls/engines/engine[3]/on-fire", 1);
                #set a listener so that if a restart is attempted, it'll fail.
                yasim_list5 = setlistener("controls/engines/engine[3]/cutoff",func {setprop("controls/engines/engine[3]/cutoff",1);});
              }
          }
      }
      
      return failed;
    }
};
var yasim_list = nil;
var yasim_list2 = nil;
var yasim_list3 = nil;
var yasim_list4 = nil;
var yasim_list5 = nil;

var repairYasim = func {
  if (yasim_list != nil) {removelistener(yasim_list); yasim_list=nil;}
  if (yasim_list2 != nil) {removelistener(yasim_list2); yasim_list2=nil;}
  if (yasim_list3 != nil) {removelistener(yasim_list3); yasim_list3=nil;}
  if (yasim_list4 != nil) {removelistener(yasim_list4); yasim_list4=nil;}
  if (yasim_list5 != nil) {removelistener(yasim_list5); yasim_list5=nil;}
  setprop("controls/engines/engine[0]/on-fire", 0);
  setprop("controls/engines/engine[1]/on-fire", 0);
  setprop("controls/engines/engine[2]/on-fire", 0);
  setprop("controls/engines/engine[3]/on-fire", 0);
  setprop("sim/crashed", 0);
  var failure_modes = FailureMgr._failmgr.failure_modes;
  var mode_list = keys(failure_modes);

    foreach(var failure_mode_id; mode_list) {
      FailureMgr.set_failure_level(failure_mode_id, 0);
    }
}

setlistener("/sim/signals/reinit", repairYasim);

hp_f = [hp_max,hp_max,hp_max,hp_max,hp_max,hp_max,hp_max];

var fail_fleet_systems = func (probability, factor) {
  var no = 7;
  while (no > 6 or hp_f[no] < 0) {
    no = int(rand()*7);
    if (hp_f[no] < 0) {
      if (rand() > 0.9) {
        armament.defeatSpamFilter("You shot one of our already sinking ships, you are just mean.");
        hp_f[no] -= factor * probability*(0.75+rand()*0.25);# from 75 to 100% damage
        print("HP["~no~"]: " ~ hp_f[no] ~ "/" ~ hp_max);
        return;
      }
    }
  }
  hp_f[no] -= factor * probability*(0.75+rand()*0.25);# from 75 to 100% damage
  printf("HP[%d]: %d/%d", no, hp_f[no], hp_max);
  #setprop("sam/damage", math.max(0,100*hp/hp_max));#used in HUD
  if ( hp_f[no] < 0 ) {
    setprop("/sim/multiplay/generic/bool["~(no+40)~"]",1);
    armament.defeatSpamFilter("So you sank one of our ships, we will get you for that!");
    if (!getprop("/carrier/disabled") and hp_f[0]<0 and hp_f[1]<0 and hp_f[2]<0) {
      setprop("/carrier/disabled",1);
      armament.defeatSpamFilter("Captain our offensive capability is crippled!");
    }
    if (hp_f[0]<0 and hp_f[1]<0 and hp_f[2]<0 and hp_f[3]<0 and hp_f[4]<0 and hp_f[5]<0 and hp_f[6]<0) {
      setprop("/carrier/sunk",1);
      setprop("/sim/multiplay/generic/int[2]",1);#radar off
      setprop("/sim/messages/copilot", getprop("sim/multiplay/callsign")~" dead.");
      armament.defeatSpamFilter("S.O.S. Heeelp");
    } else {
      armament.defeatSpamFilter("This is not over yet..");
    }    
  }
  return -1;
};

setlistener("payload/armament/MLW-count", func {
  setLaunch(getprop("payload/armament/MLW-launcher"), 0);#TODO: figure out if that callsign is a SAM/ship.
});

var setLaunch = func (c,s) {
  setprop("sound/rwr-launch-sam", s);
  setprop("sound/rwr-launch", c);
  settimer(func {stopLaunch();},7);
}

var stopLaunch = func () {
  setprop("sound/rwr-launch", "");
  setprop("sound/rwr-launch-sam", 0);
}

var playIncomingSound = func (clock) {
  setprop("sound/incoming"~clock, 1);
  settimer(func {stopIncomingSound(clock);},3);
}

var stopIncomingSound = func (clock) {
  setprop("sound/incoming"~clock, 0);
}

var nearby_explosion = func {
  setprop("damage/sounds/nearby-explode-on", 0);
  settimer(nearby_explosion_a, 0);
}

var nearby_explosion_a = func {
  setprop("damage/sounds/nearby-explode-on", 1);
  settimer(nearby_explosion_b, 0.5);
}

var nearby_explosion_b = func {
  setprop("damage/sounds/nearby-explode-on", 0);
}

var callsign_struct = {};
var getCallsign = func (callsign) {
  var node = callsign_struct[callsign];
  return node;
}

var MAW_elapsed = 0;

var processCallsigns = func () {
  callsign_struct = {};
  var players = props.globals.getNode("ai/models").getChildren();
  var myCallsign = getprop("sim/multiplay/callsign");
  myCallsign = size(myCallsign) < 8 ? myCallsign : left(myCallsign,7);
  var painted = 0;
  foreach (var player; players) {
    if(player.getChild("valid") != nil and player.getChild("valid").getValue() == TRUE and player.getChild("callsign") != nil and player.getChild("callsign").getValue() != "" and player.getChild("callsign").getValue() != nil) {
      var callsign = player.getChild("callsign").getValue();
      callsign_struct[callsign] = player;
      var str6 = player.getNode("sim/multiplay/generic/string[6]");
      if (str6 != nil and str6.getValue() != nil and str6.getValue() != "" and size(""~str6.getValue())==4 and left(md5(myCallsign),4) == str6.getValue()) {
        painted = 1;
      }
    }
  }
  setprop("payload/armament/spike", painted);
  if (getprop("sim/time/elapsed-sec")-MAW_elapsed > 1.1) {
      setprop("payload/armament/MAW-active", 0);# resets every 1.1 seconds without warning
  }
}
processCallsignsTimer = maketimer(1.5, processCallsigns);
processCallsignsTimer.simulatedTime = 1;
processCallsignsTimer.start();

var code_ct = func () {
  #ANTIC
  if (getprop("payload/armament/msg")) {
      setprop("sim/rendering/redout/enabled", TRUE);
      #call(func{fgcommand('dialog-close', multiplayer.dialog.dialog.prop())},nil,var err= []);# props.Node.new({"dialog-name": "location-in-air"}));
      call(func{multiplayer.dialog.del();},nil,var err= []);
      if (!getprop("gear/gear[0]/wow")) {
        call(func{fgcommand('dialog-close', props.Node.new({"dialog-name": "WeightAndFuel"}))},nil,var err2 = []);
        call(func{fgcommand('dialog-close', props.Node.new({"dialog-name": "system-failures"}))},nil,var err2 = []);
        call(func{fgcommand('dialog-close', props.Node.new({"dialog-name": "instrument-failures"}))},nil,var err2 = []);
      }      
      setprop("sim/freeze/fuel",0);
      setprop("/sim/speed-up", 1);
      setprop("/gui/map/draw-traffic", 0);
      setprop("/sim/gui/dialogs/map-canvas/draw-TFC", 0);
      fgcommand("timeofday", props.Node.new({"timeofday": "real"}));
      #setprop("/sim/rendering/als-filters/use-filtering", 1);
      call(func{var interfaceController = fg1000.GenericInterfaceController.getOrCreateInstance();
      interfaceController.stop();},nil,var err2=[]);      
  }  
}
code_ctTimer = maketimer(1, code_ct);
code_ctTimer.simulatedTime = 1;



setprop("/sim/failure-manager/display-on-screen", FALSE);

code_ctTimer.start();

var re_init = func (node) {
  # repair the aircraft
  if (node.getValue() == 0) return;
  
  var failure_modes = FailureMgr._failmgr.failure_modes;
  var mode_list = keys(failure_modes);

  foreach(var failure_mode_id; mode_list) {
    FailureMgr.set_failure_level(failure_mode_id, 0);
  }
  damageLog.push("Aircraft was repaired due to re-init.");
}

var damageLog = events.LogBuffer.new(echo: 0);

damageLog.push("Flightgear "~getprop("sim/version/flightgear")~" was loaded up with "~getprop("sim/description")~" - "~getprop("sim/time/gmt"));

setlistener("/sim/signals/reinit", re_init, 0, 0);

setlistener("payload/armament/msg", func {damageLog.push("Damage is now "~(getprop("payload/armament/msg")?"ON.":"OFF."));}, 1, 0);

setlistener("sim/multiplay/callsign", func {damageLog.push("Callsign is now "~getprop("sim/multiplay/callsign"));}, 1, 0);

setlistener("sim/multiplay/online", func {damageLog.push(getprop("sim/multiplay/online")?("Connected to "~getprop("sim/multiplay/txhost")):"Disconnected from MP.");}, 1, 0);

var printDamageLog = func {
  if (getprop("payload/armament/msg")) {print("disable damage to use this function");return;}
  var buffer = damageLog.get_buffer();
  var str = "";
  foreach(entry; buffer) {
      str = str~"    "~entry.time~" "~entry.message~"\n";
  }
  print();
  print(str);
  print();
}

#TODO testing:

var writeDamageLog = func {
  var output_file = getprop("/sim/fg-home") ~ "/Export/emesary-war-combat-log.txt";
  var buffer = damageLog.get_buffer();
  var str = "\n";
  foreach(entry; buffer) {
      str = str~"    "~entry.time~" "~entry.message~"\n";
  }
  str = str ~ "\n";
  var file = nil;
  if (io.stat(output_file) == nil) {
    file = io.open(output_file, "w");
    io.close(file);
  }
  file = io.open(output_file, "a");
  io.write(file, str);
  io.close(file);
  settimer(writeDamageLog, 600);
}

settimer(writeDamageLog, 600);

#screen.property_display.add("payload/armament/MAW-bearing");
#screen.property_display.add("payload/armament/MAW-active");
#screen.property_display.add("payload/armament/MLW-bearing");
#screen.property_display.add("payload/armament/MLW-count");
#screen.property_display.add("payload/armament/MLW-launcher");
#screen.property_display.add("payload/armament/spike");