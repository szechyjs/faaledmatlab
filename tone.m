function tone(ss_cf, ss_d)

ss_sf = 22050;
ss_n = ss_sf*ss_d;
ss_s = (1:ss_n) /ss_sf;
ss_s = sin(2*pi * ss_cf  * ss_s);

sound(ss_s, ss_sf);
end