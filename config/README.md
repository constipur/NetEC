Use these two scripts to ensure the same configuration on each machine.

Important configurations:

--syscyl.conf:

window_scaling,rmem,wmem,mem: now 2^7, determined by mem

sack: must enable

congestion algorithm: reno more stable, cubic probably need timestamp

--config.sh

MSS

tx off
