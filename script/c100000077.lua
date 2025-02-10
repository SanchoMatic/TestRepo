-- ダークセージソウル Dark Sage Soul
local s, id = GetID()

function s.initial_effect(c)
  -- Banish when leaving the field
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e1:SetCondition(s.rmcon)
  e1:SetValue(LOCATION_REMOVED)
  c:RegisterEffect(e1)

  -- Change level to 7 and Special Summon
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 0))
  e2:SetCategory(CATEGORY_LVCHANGE + CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_HAND + LOCATION_GRAVE)
  e2:SetCountLimit(1, id)
  e2:SetCondition(s.lvcon)
  e2:SetCost(s.lvcost)
  e2:SetTarget(s.lvtg)
  e2:SetOperation(s.lvop)
  c:RegisterEffect(e2)
end

function s.rmcon(e)
  return e:GetHandler():IsFaceup()
end

function s.lvcon(e, tp, eg, ep, ev, re, r, rp)
  return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace, RACE_SPELLCASTER), tp, LOCATION_MZONE, 0, 1, nil) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute, ATTRIBUTE_DARK), tp, LOCATION_MZONE, 0, 1, nil) and Duel.GetTurnPlayer() == tp
end

function s.lvfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK) and not c:IsType(TYPE_XYZ) and c:IsLevelAbove(1) and c:GetLevel() ~= 7
end

function s.lvcost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingTarget(s.lvfilter, tp, LOCATION_MZONE, 0, 1, nil)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
  local g = Duel.SelectTarget(tp, s.lvfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
  e:SetLabelObject(g:GetFirst())
end

function s.lvtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.lvop(e, tp, eg, ep, ev, re, r, rp)
  local tc = e:GetLabelObject()
  if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetLevel() ~= 7 then
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetValue(7)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(e1)
    Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
  end
end