# Runs the power model
# @power.mod is the model output

#Run the power model
power.mod.all <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(power.mod.all) <- c("Pred_Year", "Mod", "ModType", "Pred4", "Pred5")

#
for(y in data$yr[8]:2021) {
  power.mod.all[nrow(power.mod.all) + 1,] <- RunModRetro.new(data, y, "Power")$Preds_Out
}

power.mod.all <- power.mod.all |>
  mutate(R_Pred=Pred4+Pred5)
