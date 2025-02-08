-- Magician's Wrath
local s,id=GetID(94864059)
-- List the names of referenced cards
s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    -- Activate 1 of 2 effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    return c:IsCode(CARD_DARK_MAGICIAN) and c:IsAbleToRemove()
end

function s.other_monster_filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and not c:IsCode(CARD_DARK_MAGICIAN)
end

function s.fusion_filter(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end

function s.synchro_filter(c,e,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

function s.material_filter(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove()
end

function s.tuner_filter(c)
    return c:IsType(TYPE_TUNER) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove() and c:GetLevel()>0
end

function s.non_tuner_filter(c)
    return not c:IsType(TYPE_TUNER) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove() and c:GetLevel()>0
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and 
           Duel.IsExistingMatchingCard(s.other_monster_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) and 
                      (Duel.IsExistingMatchingCard(s.fusion_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil,nil,nil) or 
                      Duel.IsExistingMatchingCard(s.synchro_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)) end
    local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    e:SetLabel(op)
    if op==0 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    else
        e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SYNCHRO_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
        local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToRemove,nil)
        mg:Merge(Duel.GetMatchingGroup(s.other_monster_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil))
        local sg1=Duel.GetMatchingGroup(s.fusion_filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
        if #sg1>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local tc=sg1:Select(tp,1,1,nil):GetFirst()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
            tc:SetMaterial(mat1)
            Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
            s.gain_effect(tc,e,tp)
        end
    else
        local tuner=Duel.GetMatchingGroup(s.tuner_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
        local non_tuner=Duel.GetMatchingGroup(s.material_filter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
        local valid_synchros=Duel.GetMatchingGroup(s.synchro_filter,tp,LOCATION_EXTRA,0,nil,e,tp)
        valid_synchros=valid_synchros:Filter(function(sc)
            for tc1 in aux.Next(tuner) do
                for tc2 in aux.Next(non_tuner) do
                    if tc1:GetLevel()+tc2:GetLevel()==sc:GetLevel() then return true end
                end
            end
            return false
        end)
        
        if #valid_synchros>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local synchro=valid_synchros:Select(tp,1,1,nil):GetFirst()
            local lv=synchro:GetLevel()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local mat1=tuner:FilterSelect(tp,function(c) return c:GetLevel()<=lv end,1,1,nil)
            lv=lv-mat1:GetFirst():GetLevel()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local mat2=non_tuner:FilterSelect(tp,function(c) return c:GetLevel()<=lv end,1,lv,nil)
            mat1:Merge(mat2)
            Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT)
            Duel.SpecialSummon(synchro,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
            synchro:CompleteProcedure()
            s.gain_effect(synchro,e,tp)
        end
    end
end

function s.gain_effect(tc,e,tp)
    -- Effect: Inflict damage when opponent adds a card to their hand from the main deck
    local e1=Effect.CreateEffect(tc)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.damcon)
    e1:SetOperation(s.damop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp) and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DECK) and not eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_DRAW)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_MZONE,0,nil,RACE_SPELLCASTER)
    if ct>0 then
        Duel.Damage(1-tp,ct*300,REASON_EFFECT)
    end
end