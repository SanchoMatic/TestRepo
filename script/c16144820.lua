--Blacklord's Parlay
local s,id=GetID()
function s.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  --Banish to set
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_LEAVE_GRAVE)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id+1,EFFECT_COUNT_CODE_OATH)
  e2:SetCondition(aux.exccon)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.settg)
  e2:SetOperation(s.setop)
  c:RegisterEffect(e2)
end
s.listed_series={0x2226}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.synfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
    and Duel.IsExistingMatchingCard(s.synfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
end
function s.synfilter1(c,tp)
  return c:IsSetCard(0x2226) and c:IsType(TYPE_TUNER) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.synfilter2(c,tp)
  return c:IsSetCard(0x2226) and not c:IsType(TYPE_TUNER) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.synfilter3(c,tp)
  return c:IsSetCard(0x2226) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    return Duel.IsExistingMatchingCard(s.synfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
      and Duel.IsExistingMatchingCard(s.synfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
      and Duel.IsExistingMatchingCard(s.synfilter2,tp,LOCATION_EXTRA,0,1,nil,tp)
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.synfilter2),tp,LOCATION_EXTRA,0,1,1,nil,tp)
  if #g>0 then
    local sc=g:GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.synfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.synfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
    if #g1>0 and #g2>0 then
      g1:Merge(g2)
      Duel.SendtoGrave(g1,REASON_EFFECT)
      Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
      sc:CompleteProcedure()
    end
  end
end
function s.setfilter(c)
  return c:IsSetCard(0x2226) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
  local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  if #g>0 then
    Duel.SSet(tp,g)
  end
end
