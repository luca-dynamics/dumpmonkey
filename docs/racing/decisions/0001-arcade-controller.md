# ADR 0001: authored arcade motorcycle controller

Accepted by owner on 2026-10-16.

Use CharacterBody3D with custom acceleration, braking, steering, gravity and ground contact. Keep physical translation separate from the visual rig. Author a recoverable wheelie balance model and rotate presentation around the rear-wheel pivot.

Reason: responsive browser-first arcade play and controllable balancing are the immediate product requirements. A custom RigidBody3D simulation may provide richer contact but adds substantial tuning risk. VehicleBody3D is car-oriented and is not the foundation for this game.

Consequence: suspension, grip, slope response, collision presentation and stunt behavior are our responsibility. The initial controller is a hypothesis to validate against curbs, ramps and hands-on driving; passing scripted checks does not establish enjoyable handling. Revisit with the owner if contact quality requires changing the body model.

The premium first playable remains Crew Yard, one rider/bike, practice and time trial with wheelies. It is not a commitment to full motorcycle simulation or to shipping procedural study meshes as final art.
