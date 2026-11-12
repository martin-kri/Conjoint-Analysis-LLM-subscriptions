# Sources used to set the attribute levels

## LLM subscriptions
Two designs are prepared. The free-option version uses Google's real student and regular prices (EUR 5.49 / 12.99 / 21.99). The price-level version uses EUR 0 / 7.99 / 20.99: EUR 7.99 is close to ChatGPT Go (about EUR 8) and EUR 20.99 to the regular price of the paid plans (about EUR 21-25).

- Google student offers in Italy: screenshot `google_student_offers_screenshot_2026-11-08.png` (AI Pro EUR 5.49/month for up to 4 years, AI Pro + YouTube Premium EUR 12.99/month, then EUR 21.99/month)
- Gemini usage limits by plan (AI Plus 2x, AI Pro 4x the standard limits): https://support.google.com/gemini/answer/17004136
- Gemini limits are compute-based, with no fixed number of prompts: https://www.ai-toolbox.co/gemini-management-and-productivity/gemini-usage-limits-2026
- AI assistant prices in Italy (paid plans around EUR 21-25 a month): https://tech-insider.org/it/best-ai-chatbots/
- ChatGPT plans (Go with ads, Plus): https://tldv.io/it/blog/chatgpt-pricing/
- ChatGPT Go in Italy, EUR 8 vs EUR 23 for Plus: https://www.tecnoandroid.it/news/chatgpt-ecco-ufficialmente-il-piano-go-e-la-versione-con-pubblicita-1734116/
- ChatGPT Go, about 10x the free capacity: https://www.cometapi.com/it/how-much-is-chatgpt-go/
- Free Google AI Plus year for Italian university students: https://pasqualepillitteri.it/news/13234/gemini-gratis-un-anno-studenti-universitari
- Student bundle up to four years (US): https://www.macrumors.com/2026/08/19/students-free-year-google-ai-pro/
- AI use among Italian university students (83% have used it, 49% regularly): https://www.studentville.it/utilizzo-ia-ambito-accademico-rivoluzione-trasversale/


## Literature
- Aizaki, H. (2012). Basic functions for supporting an implementation of choice experiments in R. *Journal of Statistical Software*, 50(Code Snippet 2). (`support.CEs`: rotation, mix-and-match and L^MA designs)
- Chapman, C., & Feit, E. M. (2019). *R for Marketing Research and Analytics* (2nd ed.). Springer. (choice modelling, share prediction, sample-size simulation)
- Croissant, Y. (2020). Estimation of random utility models in R: The mlogit package. *Journal of Statistical Software*, 95(11).
- Louviere, J. J., Hensher, D. A., & Swait, J. D. (2000). *Stated Choice Methods: Analysis and Applications*. Cambridge University Press. (choice set construction)
- Rao, V. R. (2014). *Applied Conjoint Analysis*. Springer. (section 2.4 on selecting attributes and levels, section 2.5.8 on removing implausible profiles, section 4.4 on choice set design)
- Shampanier, K., Mazar, N., & Ariely, D. (2007). Zero as a special price: The true value of free products. *Marketing Science*, 26(6).
- Traets, F., Sanchez, D. G., & Vandebroek, M. (2020). Generating optimal designs for discrete choice experiments in R: The idefix package. *Journal of Statistical Software*, 96(3).
