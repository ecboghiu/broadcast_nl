function OutputBellIneq = Transform_NPartite_BellInequaliy(Type,Scenario,InputBellIneq)

%'Type' should be either 'full', 'CG'

%'Scenario' is a 2-dimensional matrix of the form:
%[Oa|x=1, Oa|x=2, Oa|x=3, …, Oa|x=N_x,
% Ob|y=1, Ob|y=2, Ob|y=3, …, Ob|y=N_y,
% Oc|z=1, Oc|z=2, Oc|z=3  ...]


Num_Parties = size(Scenario,1);
Num_Inputs_EachParty = zeros(1,Num_Parties);
for i =1:Num_Parties
    Num_Inputs_EachParty(i) = length(find(Scenario(i,:)~=0));
end
Max_NumOutcomes_EachParty = max(Scenario');
if isequal(Type,'full')
    assert(isequal(size(InputBellIneq),[Max_NumOutcomes_EachParty,Num_Inputs_EachParty]),'Dimension of the given target mismatches with the specified Bell scenario.')
    Output_abc_FillingIndex = cell(1,Num_Parties); Output_xyz_FillingIndex = cell(1,Num_Parties);
    Input_abc_FillingIndex = cell(1,Num_Parties); Input_xyz_FillingIndex = cell(1,Num_Parties);
    OutputBellIneq = zeros([Max_NumOutcomes_EachParty-1,Num_Inputs_EachParty+1]);
    for k_PartiesMarginal=1:Num_Parties
        AllPossibleRelatedParties_for_MarginalTerms = nchoosek(1:Num_Parties,k_PartiesMarginal);
        for ith_PartiesCombinationsOfMarginalTerms =1:size(AllPossibleRelatedParties_for_MarginalTerms,1)
            RelatedParties_for_MarginalTerms = AllPossibleRelatedParties_for_MarginalTerms(ith_PartiesCombinationsOfMarginalTerms,:);
            UnRelatedParties_for_MarginalTerms= setdiff(1:Num_Parties,RelatedParties_for_MarginalTerms);
            for j =1:length(UnRelatedParties_for_MarginalTerms)
                Output_abc_FillingIndex{UnRelatedParties_for_MarginalTerms(j)} = 1;
                Output_xyz_FillingIndex{UnRelatedParties_for_MarginalTerms(j)} = Num_Inputs_EachParty(UnRelatedParties_for_MarginalTerms(j))+1;
            end
            NumInptus_of_RelatedParties = Num_Inputs_EachParty(RelatedParties_for_MarginalTerms);
            NumOutputs_of_RelatedParties = Scenario(RelatedParties_for_MarginalTerms,:);
            NumInptus_of_UnRelatedParties = Num_Inputs_EachParty(UnRelatedParties_for_MarginalTerms);
            NumOutputs_of_UnRelatedParties = Scenario(UnRelatedParties_for_MarginalTerms,:);
            TmpNumOutputs_of_RelatedParties_GivenInputs = zeros(1,length(RelatedParties_for_MarginalTerms));
            for m_choice_of_inputs = 1:prod(NumInptus_of_RelatedParties)
                [Output_xyz_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(NumInptus_of_RelatedParties,m_choice_of_inputs);
                [Input_xyz_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(NumInptus_of_RelatedParties,m_choice_of_inputs);
                for i = 1:length(RelatedParties_for_MarginalTerms)
                    TmpNumOutputs_of_RelatedParties_GivenInputs(i) = NumOutputs_of_RelatedParties(i,Output_xyz_FillingIndex{RelatedParties_for_MarginalTerms(i)});
                end
                for zth_possible_abcindex = 1:prod(TmpNumOutputs_of_RelatedParties_GivenInputs-1)
                    [Output_abc_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(TmpNumOutputs_of_RelatedParties_GivenInputs-1,zth_possible_abcindex);
                    TmpValue = 0;
                    for mth_possible_xyz_index_of_unrelatedparties = 1:prod(NumInptus_of_UnRelatedParties)
                        [Input_xyz_FillingIndex{[UnRelatedParties_for_MarginalTerms]}] = ind2sub(NumInptus_of_UnRelatedParties,mth_possible_xyz_index_of_unrelatedparties);
                        for tth_unrelatedparties = 1:length(UnRelatedParties_for_MarginalTerms)
                            Input_abc_FillingIndex{UnRelatedParties_for_MarginalTerms(tth_unrelatedparties)} = NumOutputs_of_UnRelatedParties(tth_unrelatedparties,Input_xyz_FillingIndex{...
                                UnRelatedParties_for_MarginalTerms(tth_unrelatedparties)});
                        end
                        [Input_abc_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(TmpNumOutputs_of_RelatedParties_GivenInputs-1,zth_possible_abcindex);
                        for num_chosen_parties = 0:length(RelatedParties_for_MarginalTerms)
                            if num_chosen_parties==0
                                TmpValue = TmpValue + InputBellIneq(Input_abc_FillingIndex{:},Input_xyz_FillingIndex{:});
                            else
                                [Input_abc_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(TmpNumOutputs_of_RelatedParties_GivenInputs-1,zth_possible_abcindex);
                                AllPossibleChosen_Parties = nchoosek(RelatedParties_for_MarginalTerms,num_chosen_parties);
                                for lth_combinations_of_chosenparties = 1:size(AllPossibleChosen_Parties,1)
                                    [Input_abc_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(TmpNumOutputs_of_RelatedParties_GivenInputs-1,zth_possible_abcindex);
                                    for each_chosen_parties = 1:num_chosen_parties
                                        [Input_abc_FillingIndex{AllPossibleChosen_Parties(lth_combinations_of_chosenparties,each_chosen_parties)}] = NumOutputs_of_RelatedParties(each_chosen_parties,...
                                            Output_xyz_FillingIndex{RelatedParties_for_MarginalTerms(each_chosen_parties)});
                                    end
                                    TmpValue = TmpValue + (-1)^(num_chosen_parties)*InputBellIneq(Input_abc_FillingIndex{:},Input_xyz_FillingIndex{:});
                                end
                            end
                            
                        end
                    end
                    OutputBellIneq(Output_abc_FillingIndex{:},Output_xyz_FillingIndex{:}) = TmpValue;
                end
            end
        end
    end
    TmpValue = 0;
    for i =1:Num_Parties
        Output_xyz_FillingIndex{i} = Num_Inputs_EachParty(i)+1;
        Output_abc_FillingIndex{i} = 1;
    end
    for i = 1:prod(Num_Inputs_EachParty)
        [Input_xyz_FillingIndex{:}] = ind2sub(Num_Inputs_EachParty,i);
        for k =1:Num_Parties
            Input_abc_FillingIndex{k} = Scenario(k,Input_xyz_FillingIndex{k});
        end
        TmpValue = TmpValue + InputBellIneq(Input_abc_FillingIndex{:},Input_xyz_FillingIndex{:});
    end
    OutputBellIneq(Output_abc_FillingIndex{:},Output_xyz_FillingIndex{:}) = TmpValue;
elseif isequal(Type,'CG')
    assert(isequal(size(InputBellIneq),[Max_NumOutcomes_EachParty-1,Num_Inputs_EachParty+1]),'Dimension of the given target mismatches with the specified Bell scenario.')
    OutputBellIneq = zeros([Max_NumOutcomes_EachParty,Num_Inputs_EachParty]);
    Output_abc_FillingIndex = cell(1,Num_Parties); Output_xyz_FillingIndex = cell(1,Num_Parties);
    Input_abc_FillingIndex = cell(1,Num_Parties);  Input_xyz_FillingIndex = cell(1,Num_Parties);
    
    for k_PartiesMarginal=0:Num_Parties
        AllPossibleRelatedParties_for_MarginalTerms = nchoosek(1:Num_Parties,k_PartiesMarginal);
        for ith_PartiesCombinationsOfMarginalTerms =1:size(AllPossibleRelatedParties_for_MarginalTerms,1)
            RelatedParties_for_MarginalTerms = AllPossibleRelatedParties_for_MarginalTerms(ith_PartiesCombinationsOfMarginalTerms,:);
            UnRelatedParties_for_MarginalTerms= setdiff(1:Num_Parties,RelatedParties_for_MarginalTerms);
            
            NumInptus_of_RelatedParties = Num_Inputs_EachParty(RelatedParties_for_MarginalTerms);
            NumOutputs_of_RelatedParties = Scenario(RelatedParties_for_MarginalTerms,:);
            NumInptus_of_UnRelatedParties = ones(1,length(UnRelatedParties_for_MarginalTerms));
            NumOutputs_of_UnRelatedParties = Scenario(UnRelatedParties_for_MarginalTerms,1);
            TmpNumOutputs_of_RelatedParties_GivenInputs = zeros(1,length(RelatedParties_for_MarginalTerms));          
            
            for j =1:length(UnRelatedParties_for_MarginalTerms)
                Input_xyz_FillingIndex{UnRelatedParties_for_MarginalTerms(j)} = Num_Inputs_EachParty(UnRelatedParties_for_MarginalTerms(j))+1;
                Output_xyz_FillingIndex{UnRelatedParties_for_MarginalTerms(j)} = 1;                
                Input_abc_FillingIndex{UnRelatedParties_for_MarginalTerms(j)} = 1; 
                Output_abc_FillingIndex{UnRelatedParties_for_MarginalTerms(j)} = 1:NumOutputs_of_UnRelatedParties(j);
            end
            
            for m_choice_of_inputs = 1:prod(NumInptus_of_RelatedParties)
                [Output_xyz_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(NumInptus_of_RelatedParties,m_choice_of_inputs);
                [Input_xyz_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(NumInptus_of_RelatedParties,m_choice_of_inputs);
                for i = 1:length(RelatedParties_for_MarginalTerms)
                    TmpNumOutputs_of_RelatedParties_GivenInputs(i) = NumOutputs_of_RelatedParties(i,Output_xyz_FillingIndex{RelatedParties_for_MarginalTerms(i)});
                end
                for zth_possible_abcindex = 1:prod(TmpNumOutputs_of_RelatedParties_GivenInputs-1)
                    [Output_abc_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(TmpNumOutputs_of_RelatedParties_GivenInputs-1,zth_possible_abcindex);
                    [Input_abc_FillingIndex{[RelatedParties_for_MarginalTerms]}] = ind2sub(TmpNumOutputs_of_RelatedParties_GivenInputs-1,zth_possible_abcindex);                  
                    OutputBellIneq(Output_abc_FillingIndex{:},Output_xyz_FillingIndex{:}) = OutputBellIneq(Output_abc_FillingIndex{:},Output_xyz_FillingIndex{:}) + InputBellIneq(Input_abc_FillingIndex{:},Input_xyz_FillingIndex{:})*ones(size( OutputBellIneq(Output_abc_FillingIndex{:},Output_xyz_FillingIndex{:})));
                end
            end
        end
    end
end
end
