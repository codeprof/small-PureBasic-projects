Tiny procedure to check if two images are similar.
It returns a 192 Bit checksum which can be compared to other checksums. 
In contrast to a "normal" checksum(hash) this procedure will return a similar checksum if the two images are similar.
The two images can have different sizes,quality, brightness, contrast, saturation, tinit, noise and will be still considered as the same or similar (only a few bits change).
Not supported at the moment is rotation and horz./vert. flip.
