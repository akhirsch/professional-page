---
title: First-Order Logic for Flow-Limited Authorization
---

Authorization decisions based on user data may require careful reasoning in order to not break user policies.
For instance, basing an authorization decision off of a private friends list may leak information about who is on that list.
Flow-limited authorization combines static information-flow labels with authorization logic in order to ensure that user privacy and integrity policies are followed while making authorization decisions.
However, previous work had very limited logical structure or connection with traditional authorization logic.
This project fixes both by providing a first-order multi-modal logic for reasoning about flow-limited authorization.

My work on FLAFOL is listed below:

- [First-Order Logic for Flow-Limited Authorization](/pubs/first_order_logic_for_flow_limited_authorization.html)
With Pedro H. Azevedo de Amorim, Ethan Cecchetti, Ross Tate, and Owen Arden
Published as Cornell University Technical Report, 2019.
In submission.
