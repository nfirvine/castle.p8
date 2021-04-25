# castle.p8
Castle Adventure on pico-8

I wanted to learn some pico-8 on a lazy weekend, so I decided to try to port my oldest computer memory, Castle Adventure (<a href="https://archive.org/details/msdos_Castle_Adventure_1984">the original is playable on archive.org</a>, though I think it runs too fast). 

Well turns out it's not going to be too straightforward. There's too much level data to fit on a pico-8 cart. Rooms are 24x18 cells, so we can fit 128//24 = 5 per row and 64//18 = 3 per column, for a total of 15. I haven't counted by I wager there's gotta be 50 rooms in the original.

The orignal rooms being 24x18 presents a challenge: we need a pan-and-scan camera, not just a room-hopping one. This would make the game a little harder, since you'd have to venture into the room to see the whole thing.

I got player movement, camera tracking, and moving between rooms working. Not much, but it's my first day :)
